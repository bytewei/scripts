import socket

def check_aliveness(ip, port):
    sk = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sk.settimeout(1)
    try:
        sk.connect((ip,port))
#        print 'service is OK!'
        print '1'
        return True
    except Exception:
#        print 'service is NOT OK!'
        print '0'
        return False
    finally:
        sk.close()
    return False

check_aliveness('127.0.0.1', 5672)
