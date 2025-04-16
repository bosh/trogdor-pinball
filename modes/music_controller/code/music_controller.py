from mpf.core.mode import Mode

class MusicController(Mode):
  def mode_init(self):
    self.machine.log.info("TrogPy::MusicController initialized")

  def mode_start(self, **kwargs):
    self.machine.log.info("TrogPy::MusicController starting")

  def mode_stop(self, **kwargs):
    self.machine.log.info("TrogPy::MusicController stopping")
