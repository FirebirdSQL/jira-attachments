#!/usr/bin/env python
import fdb
import threading

dsn = 'localhost:/home/hamish/foo.fdb'
#dsn = '192.168.42.2:/home/hamish/foo.fdb'
#dsn = 'hamish-win7:c:/dev/rising_cpp/projects/server/http_ibase_server/localhost.fdb'

class workthread(threading.Thread):
	def __init__(self, number):
		threading.Thread.__init__(self)
		self._number = number

	def run(self):
		for i in range(1000):
			print("Thread %d connection %d" % (self._number, i))
			con = fdb.connect(dsn=dsn)

			try:
				with con.event_conduit(('event_name',)) as conduit:
					actual = conduit.wait(timeout=0.1)

				con.close()

			except Exception as e:
				print ("Exception", e)

			finally:
				del con



threads = []
for i in range(5):
	t = workthread(i)
	threads.append(t)
	t.start()


for t in threads:
	t.join()