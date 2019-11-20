import dropbox
from datetime import datetime, timedelta
import tzlocal
import pytz
from dropbox.file_requests import FileRequestDeadline, UpdateFileRequestDeadline, GracePeriod
from os.path import expanduser
tokenfile = expanduser('~/.dropbox_token')
with open(tokenfile,'r') as f:
  tk = f.readline().replace('\n','')
timezone = tzlocal.get_localzone().zone
timezone = pytz.timezone(timezone)

def create_request(timestamp, name, directory, late=True, token=tk):
  """
  Create a file request in Dropbox, with a deadline 
  (only for Business or Professional accounts)
  
  INPUTS:
  
  timestamp: The deadline date and time in ISO 8601 format (YYYY-MM-DDThh:mm:ss)
             in local time
  name:      The title of the file request
  directory: The destination directory for the file request. 
             It must start with '/' for the top level Dropbox directory
  late :     True/False; if True a grace period of 1 day is added.
  token:     Dropbox authentication token
  """
  # TODO: write code...
  deadline = datetime.fromisoformat(timestamp)
  deadline_time = timezone.localize(deadline, is_dst=True)
  deadline_utc = deadline_time.astimezone(pytz.utc)
  
  dbx = dropbox.Dropbox(tk)
  requests = dbx.file_requests_list().file_requests
  names = [u for u in requests if u.title==name]
  folders = [u for u in requests if u.destination==directory]
  
  if late:
    dl = FileRequestDeadline(deadline = deadline_utc, allow_late_uploads=GracePeriod('one_day'))
  else: 
    dl = FileRequestDeadline(deadline = deadline_utc, allow_late_uploads=None)
  
  
  if len(names) > 1 or len(folders) > 1:
    raise ValueError("Duplicate requests present")
  
  if len(names) > 0:
    a = names[0]
    a1 = dbx.file_requests_update(a.id, destination=directory, open=True,
      deadline=UpdateFileRequestDeadline('update', dl))
    return(a1)
  if len(folders) > 0:
    a = folders[0]
    a1 = dbx.file_requests_update(a.id, title=name, open=True,
      deadline=UpdateFileRequestDeadline('update',dl))
    return(a1)
  
  a = dbx.file_requests_create(title=name, destination=directory, 
    deadline=dl)
  return(a)

