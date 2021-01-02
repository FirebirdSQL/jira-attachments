#!/usr/bin/env python
import fdb
import threading

dsn = 'localhost:/home/hamish/foo.fdb'

class workthread(threading.Thread):
	def __init__(self, number):
		threading.Thread.__init__(self)
		self._number = number

	def run(self):
		for i in xrange(1000):
			print "Thread %d connection %d" % (self._number, i)

			con = fdb.connect(dsn=dsn)
			with con.event_conduit(('event_name',)) as conduit:
				actual = conduit.wait(timeout=0.1)
			del con

threads = []
for i in xrange(5):
	t = workthread(i)
	threads.append(t)
	t.start()


for t in threads:
	t.join()