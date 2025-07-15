import time
from mpf.core.mode import Mode

class CodeBase(Mode):
  def mode_init(self):
    self.machine.log.info("TrogPy::CodeBase initialized")

  def mode_start(self, **kwargs):
    self.machine.log.info("TrogPy::CodeBase starting")
    timestamp = time.time()
    self.machine.events.post('update_player_ball_start', timestamp=round(timestamp,2), timestamp_format=time.strftime("%Y-%m-%d %H:%M:%S"))

  def mode_stop(self, **kwargs):
    self.machine.log.info("TrogPy::CodeBase stopping")
    timestamp = time.time()
    self.machine.events.post('update_player_ball_end', timestamp=round(timestamp,2), timestamp_format=time.strftime("%Y-%m-%d %H:%M:%S"))
