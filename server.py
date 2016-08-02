#!/usr/bin/python
from rasengan import TcpStdIOShim as T
T(port=13579, cmd='syntaxnet/demo.sh', output_until='\r\n\r\n', verbose=True).execute()
