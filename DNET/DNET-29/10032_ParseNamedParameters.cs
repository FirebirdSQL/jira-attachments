		private string ParseNamedParameters(string sql)
		{
			namedParameters.Clear();

			if (sql.IndexOf('@') == -1)
				return sql;

			int l = sql.Length;

			StringBuilder builder = new StringBuilder(l, l);
			StringBuilder paramBuilder = new StringBuilder(25);

			bool inCommas = false;
			bool inParam = false;


			for (int i = 0; i < l; i++)
			{
				char sym = sql[i];
				if (inParam)
				{
					if  ((sym >= 'a' && sym <= 'z') || 
						(sym >= 'A' && sym <= 'Z') || 
						(sym >= '0' && sym <= '9') ||
						(sym == '_'))
					{
						paramBuilder.Append(sym);
					}
					else
					{
						namedParameters.Add(paramBuilder.ToString());
						paramBuilder.Length = 0;
						builder.Append('?');
						builder.Append(sym);
						inParam = false;
					}
				}
				else
				{
					if (sym == '\'')
					{
						inCommas = !inCommas;
					}
					else if (!inCommas && sym == '@')
					{
						inParam = true;
						paramBuilder.Append(sym);
						continue;
					}
					builder.Append(sym);
				}
			}

			if (inParam)
			{
				namedParameters.Add(paramBuilder.ToString());
				builder.Append('?');
			}

			return builder.ToString();
		}

