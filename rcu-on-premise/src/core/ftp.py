import sys

from ftplib import FTP, FTP_TLS


def ftp_open_connection(host, port, login, password, path, auth_method=None):
    """
    Open an ftp connection and log into corresponding path.
    """
    ftp = None
    try:
        # Create an FTP or FTP_TLS object
        if auth_method == 'tls-ftp':
            ftp = FTP_TLS()
        else:
            ftp = FTP()

        # Create the connection and log in
        ftp.connect(host, int(port))
        ftp.login(login, password)
        if auth_method == 'tls-ftp':
            ftp.prot_p()

        # Go to corresponding path
        ftp.cwd(path)
    except Exception as e:
        print('Error while opening FTP connection:', e)
        sys.exit(1)
    return ftp


def ftp_close_connection(ftp):
    """
    Close an ftp connection.
    """
    ftp.quit()
