/*
 *	PROGRAM:	JRD International support
 *	MODULE:		CsConvert.h
 *	DESCRIPTION:	International text handling definitions
 *
 *  The contents of this file are subject to the Initial
 *  Developer's Public License Version 1.0 (the "License");
 *  you may not use this file except in compliance with the
 *  License. You may obtain a copy of the License at
 *  http://www.ibphoenix.com/main.nfs?a=ibphoenix&page=ibp_idpl.
 *
 *  Software distributed under the License is distributed AS IS,
 *  WITHOUT WARRANTY OF ANY KIND, either express or implied.
 *  See the License for the specific language governing rights
 *  and limitations under the License.
 *
 *  The Original Code was created by Nickolay Samofatov
 *  for the Firebird Open Source RDBMS project.
 *
 *  Copyright (c) 2004 Nickolay Samofatov <nickolay@broadviewsoftware.com>
 *  and all contributors signed below.
 *
 *  All Rights Reserved.
 *  Contributor(s): ______________________________________.
 *
 *  2006.10.10 Adriano dos Santos Fernandes - refactored from intl_classes.h
 *
 */

#ifndef JRD_CSCONVERT_H
#define JRD_CSCONVERT_H

#include "iberror.h"
#include "../common/classes/array.h"


namespace Jrd {

class CsConvert
{
public:
	CsConvert(charset* /*const*/ cs1, charset* /*const*/ cs2)
		: charSet1(cs1),
		  charSet2(cs2),
		  cnvt1((cs1 ? &cs1->charset_to_unicode : NULL)),
		  cnvt2((cs2 ? &cs2->charset_from_unicode : NULL))
	{
		//TODO: What make this code?
		if (cs1 == NULL)
		{
			cs1 = cs2;
			cnvt1 = cnvt2;

			cs2 = NULL;
			cnvt2 = NULL;
		}
	}

	CsConvert(const CsConvert& obj)
		: charSet1(obj.charSet1),
		  charSet2(obj.charSet2),
		  cnvt1(obj.cnvt1),
		  cnvt2(obj.cnvt2)
	{
	}

public:
	// CVC: Beware of this can of worms: csconvert_convert gets assigned
	// different functions that not necessarily take the same argument. Typically,
	// the src pointer and the dest pointer use different types.
	// How does this work without crashing is a miracle of IT.

	// To be used with getConvFromUnicode method of CharSet class
	ULONG convert(ULONG         const srcLen,
				  const USHORT* const src,
				  ULONG         const dstLen,
				  UCHAR*        const dst,
				  ULONG*        const badInputPos = NULL,
				  bool          const ignoreTrailingSpaces = false)const
	{
		return this->convert(srcLen, reinterpret_cast<const UCHAR*>(src), dstLen, dst, badInputPos, ignoreTrailingSpaces);
	}

	// To be used with getConvToUnicode method of CharSet class
	ULONG convert(ULONG        const srcLen,
				  const UCHAR* const src,
				  ULONG        const dstLen,
				  USHORT*      const dst,
				  ULONG*       const badInputPos = NULL,
				  bool         const ignoreTrailingSpaces = false)const
	{
		return this->convert(srcLen, src, dstLen, reinterpret_cast<UCHAR*>(dst), badInputPos, ignoreTrailingSpaces);
	}

	// To be used for arbitrary conversions
	ULONG convert(ULONG        const srcLen,
				  const UCHAR* const src,
				  ULONG        const dstLen,
				  UCHAR*       const dst,
				  ULONG*       const badInputPos = NULL,
				  bool         const ignoreTrailingSpaces = false)const
	{
		fb_assert(srcLen==0 || src!=0);
		fb_assert(dstLen==0 || dst!=0);

		if (badInputPos)
			*badInputPos = srcLen;

		USHORT errCode = 0;
		ULONG errPos = 0;

		if (cnvt2)
		{
			Firebird::HalfStaticArray<UCHAR, BUFFER_SMALL> temp;

			fb_assert(cnvt1!=NULL);

			const ULONG src_ucs2_buffer_len = (*cnvt1->csconvert_fn_convert)(cnvt1, srcLen, NULL, 0, NULL, &errCode, &errPos);

			if (src_ucs2_buffer_len == INTL_BAD_STR_LENGTH || errCode != 0)
				Firebird::status_exception::raise(isc_arith_except, 0);

			temp.getBuffer(src_ucs2_buffer_len);

			const ULONG src_ucs2_data_len = (*cnvt1->csconvert_fn_convert)(
				cnvt1, srcLen, src, temp.getCount(), temp.begin(), &errCode, &errPos);

            fb_assert((src_ucs2_data_len%sizeof(USHORT))==0);
            fb_assert(src_ucs2_data_len<=temp.getCount());

			if (src_ucs2_data_len == INTL_BAD_STR_LENGTH)
			{
				Firebird::status_exception::raise(
					isc_arith_except,
					isc_arg_gds, isc_transliteration_failed,
					0);
			}

			if (errCode == CS_BAD_INPUT && badInputPos)
				*badInputPos = errPos;
			else if (errCode != 0)
			{
				Firebird::status_exception::raise(
					isc_arith_except,
					isc_arg_gds, isc_transliteration_failed,
					0);
			}

			const ULONG dest_len = (*cnvt2->csconvert_fn_convert)(cnvt2, src_ucs2_data_len, temp.begin(), dstLen, dst, &errCode, &errPos);

			fb_assert(dstLen==0 || dest_len==INTL_BAD_STR_LENGTH || dest_len<=dstLen);

			if (dest_len == INTL_BAD_STR_LENGTH)
			{
				Firebird::status_exception::raise(
					isc_arith_except,
					isc_arg_gds, isc_transliteration_failed,
					0);
			}
			else if (errCode != 0)
			{
				if (ignoreTrailingSpaces && errCode == CS_TRUNCATION_ERROR)
				{
					fb_assert((errPos%sizeof(USHORT))==0);
					fb_assert(errPos<=src_ucs2_data_len);

					for (const USHORT* p = reinterpret_cast<const USHORT*>(temp.begin() + errPos);
						 p < reinterpret_cast<const USHORT*>(temp.begin()+src_ucs2_data_len); ++p)
					{
						if (*p != 0x20)	// space
						{
							if (badInputPos)
							{
								*badInputPos = errPos;
								break;
							}
							else
								Firebird::status_exception::raise(isc_arith_except, 0);
						}
					}
				}
				else if (errCode == CS_TRUNCATION_ERROR)
				{
					if (badInputPos)
						*badInputPos = errPos;
					else
						Firebird::status_exception::raise(isc_arith_except, 0);
				}
				else
				{
					Firebird::status_exception::raise(
						isc_arith_except,
						isc_arg_gds, isc_transliteration_failed,
						0);
				}
			}

			return dest_len;
		}
		else
		{
			fb_assert(cnvt2==NULL);
			fb_assert(cnvt1!=NULL);

			const ULONG len = (*cnvt1->csconvert_fn_convert)(
				cnvt1, srcLen, src, dstLen, dst, &errCode, &errPos);

			if (len == INTL_BAD_STR_LENGTH)
			{
				Firebird::status_exception::raise(
					isc_arith_except,
					isc_arg_gds, isc_transliteration_failed,
					0);
			}

			if (errCode == CS_BAD_INPUT && badInputPos)
				*badInputPos = errPos;
			else if (errCode != 0)
			{
				if (ignoreTrailingSpaces && errCode == CS_TRUNCATION_ERROR)
				{
					const UCHAR* const end = src + srcLen - charSet1->charset_space_length;

					for (const UCHAR* p = src + errPos; p <= end; p += charSet1->charset_space_length)
					{
						if (memcmp(p, charSet1->charset_space_character,
								charSet1->charset_space_length) != 0)
						{
							if (badInputPos)
							{
								*badInputPos = errPos;
								break;
							}
							else
								Firebird::status_exception::raise(isc_arith_except, 0);
						}
					}
				}
				else if (errCode == CS_TRUNCATION_ERROR)
				{
					if (badInputPos)
						*badInputPos = errPos;
					else
						Firebird::status_exception::raise(isc_arith_except, 0);
				}
				else
				{
					Firebird::status_exception::raise(
						isc_arith_except,
						isc_arg_gds, isc_transliteration_failed,
						0);
				}
			}

			return len;
		}
	}//convert

	// To be used for measure length of conversion
	ULONG convertLength(ULONG const srcLen)const
	{
		USHORT errCode;
		ULONG errPos;
		ULONG len = (*cnvt1->csconvert_fn_convert)(cnvt1, srcLen, NULL, 0, NULL, &errCode, &errPos);

		if (cnvt2)
		{
			if (len != INTL_BAD_STR_LENGTH && errCode == 0)
				len = (*cnvt2->csconvert_fn_convert)(cnvt2, len, NULL, 0, NULL, &errCode, &errPos);
		}

		if (len == INTL_BAD_STR_LENGTH || errCode != 0)
			Firebird::status_exception::raise(isc_arith_except, 0);

		return len;
	}

	const char* getName() const { return cnvt1->csconvert_name; }

	csconvert* getStruct() const { return cnvt1; }

private:
	charset* charSet1;
	charset* charSet2;
	csconvert* cnvt1;
	csconvert* cnvt2;
};

}	// namespace Jrd


#endif	// JRD_CSCONVERT_H
