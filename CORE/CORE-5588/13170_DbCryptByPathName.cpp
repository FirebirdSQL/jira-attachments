/*
 *  The Original Code was created by Alex Peshkov.
 *
 *  Copyright (c) 2016 Alex Peshkov <peshkoff at mail.ru>
 *  and all contributors signed below.
 *
 *  All Rights Reserved.
 *  Contributor(s): ______________________________________.
 */

#include "firebird.h"
#include "firebird/Interface.h"

#include <fstream>
#include <string>
#include <sstream>
#include <iostream>
#include <algorithm>



using namespace Firebird;

namespace DbCryptPlugin {

class PluginModule : public IPluginModuleImpl<PluginModule, CheckStatusWrapper>
{
public:
	PluginModule()
		: pluginManager(NULL)
	{ }

	~PluginModule()
	{
		if (pluginManager)
		{
			pluginManager->unregisterModule(this);
			doClean();
		}
	}

	void registerMe(IPluginManager* m)
	{
		pluginManager = m;
		pluginManager->registerModule(this);
	}

	void doClean()
	{
		pluginManager = NULL;
	}

private:
	IPluginManager* pluginManager;
};

class DbCrypt : public Firebird::IDbCryptPluginImpl<DbCrypt, Firebird::CheckStatusWrapper>
{
private:
    IDbCryptInfo *ptr_dbCryptInfo;
    char key[16];

	void error(CheckStatusWrapper* status, const char* text, bool)
	{
		ISC_STATUS_ARRAY st;
		st[0] = isc_arg_gds;
		st[1] = isc_random;
		st[2] = isc_arg_string;
		st[3] = (ISC_STATUS) text;
		st[4] = isc_arg_end;

		status->setErrors(st);
		throw std::exception();
	}

	void xorWithKey(unsigned length, const void* from, void* to)
	{
		const UCHAR* f = (const UCHAR*)from;
		UCHAR* t = (UCHAR*)to;

		for (unsigned l = 0; l < length; ++l)
		{
			t[l] = f[l] ^ key[l & 0xF];
		}
	}

public:
	explicit DbCrypt(CheckStatusWrapper*, IPluginConfig* pc)
		: ptr_dbCryptInfo(NULL), pluginConf(pc), mRefCount(0), owner(NULL)
	{ }

	~DbCrypt()
	{
		if (ptr_dbCryptInfo)
	        ptr_dbCryptInfo->release();

		if (pluginConf)
        	pluginConf->release();
	}

    void setInfo(CheckStatusWrapper* status, IDbCryptInfo* info)
	{
		//printf("setInfo %p %s\n", info, info->getDatabaseFullPath(status));
        ptr_dbCryptInfo = info;
        ptr_dbCryptInfo->addRef();
	}

	// IDbCrypt implementation
	void setKey(CheckStatusWrapper* status, unsigned, IKeyHolderPlugin**, const char* keyName)
	{
		try
		{
            if (!ptr_dbCryptInfo)
            {
                error( status, "DbCrypt:setKey failed because ptr_dbCryptInfo is NULL. The setInfo(...) was not called or wrong FB server version is used...", false); //raise inside
            }

            const char * pszDBFullName = ptr_dbCryptInfo->getDatabaseFullPath(status);
            if (!pszDBFullName)
            {
                error( status, "DbCrypt:setKey failed because getDatabaseFullPath(...) returns NULL.", false); //raise inside
            }

            std::string WorkWithDBFile(pszDBFullName);

            //change extension of DB to ".key" - to get key file
            std::string JSONFileName=WorkWithDBFile.substr(0, WorkWithDBFile.find_last_of('.'))+".key";

            //read json file
            FILE* pFile = fopen(JSONFileName.c_str(), "rb"); // non-Windows use "r"
            if (pFile==NULL) {
                std::ostringstream emessage;
                emessage << "Error in DbCrypt plugin: the key file " << JSONFileName.c_str() << " cannot be opened!" << std::endl;
                error( status, emessage.str().c_str(), false); //raise inside
                //return;
            }

            char JSON_read_buffer[65536];
            if (!fgets(JSON_read_buffer, sizeof(JSON_read_buffer), pFile))
            {
	            fclose(pFile);
                std::ostringstream emessage;
                emessage << "Error in DbCrypt plugin: key file has an error" << std::endl;
                error( status, emessage.str().c_str(), false); //raise inside
                //return;
            }
            fclose(pFile);

			memcpy (key, JSON_read_buffer, sizeof(key));
		}
		catch(const std::exception& ex)
		{
            //error(status, ex.what(), false);
		}
	}

	void encrypt(CheckStatusWrapper* status, unsigned length, const void* from, void* to)
	{
        try {
    		if (!key)
	    		error(status, "Key not set", false);
		    xorWithKey(length, from, to);
        }
        catch(const std::exception& ex)
        {
            //error(status, ex.what(), false);
        }
	}

	void decrypt(CheckStatusWrapper* status, unsigned length, const void* from, void* to)
	{
        try {
    		if (!key)
	    		error(status, "Key not set", false);
		    xorWithKey(length, from, to);
        }
        catch(const std::exception& ex)
        {
            //error(status, ex.what(), false);
        }
	}

	int release()
	{
        if (--mRefCount == 0) {
//        if(InterlockedDecrement(&mRefCount)==0){
            delete this;
            return 0;
        }
		return 1;
	}

	void addRef()
	{
        //InterlockedIncrement(&mRefCount); 
        ++mRefCount;
	}

	void setOwner(IReferenceCounted* o)
	{
		owner = o;
	}

	IReferenceCounted* getOwner()
	{
		return owner;
	}

private:
	IPluginConfig* pluginConf;
    volatile unsigned int mRefCount; //was std::atomic<int> refCounter;
	IReferenceCounted* owner;
};

class Factory : public IPluginFactoryImpl<Factory, CheckStatusWrapper>
{
public:
	IPluginBase* createPlugin(CheckStatusWrapper* status, IPluginConfig* factoryParameter)
	{
		DbCrypt* p = new DbCrypt(status, factoryParameter);
		p->addRef();
		return p;
	}
};

// register plugin
static PluginModule module;
static Factory factory;

} // namespace DbCryptPlugin

extern "C" void FB_EXPORTED FB_PLUGIN_ENTRY_POINT(Firebird::IMaster* master)
{
	IPluginManager* pluginManager = master->getPluginManager();

	DbCryptPlugin::module.registerMe(pluginManager);
	pluginManager->registerPluginFactory(Firebird::IPluginManager::TYPE_DB_CRYPT,
		"DbCrypt_example", &DbCryptPlugin::factory);
}
