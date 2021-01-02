private IPAddress GetIPAddress(string dataSource, AddressFamily addressFamily)
{
	try
	{
		return IPAddress.Parse(dataSource);               
	}
	catch (Exception ex)
	{
		try
		{
			IPAddress[] addresses = Dns.GetHostEntry(dataSource).AddressList;

			// Try to avoid problems with IPV6 addresses
			foreach (IPAddress address in addresses)
			{
				if (address.AddressFamily == addressFamily)
				{
					return address;
				}
			}

			return addresses[0];
		}
	}
}