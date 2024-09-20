from mpf.core.mode import Mode

class CodeBase(Mode):
  def mode_init(self):
    self.machine.log.info("TrogPy::CodeBase initialized")

  def mode_start(self, **kwargs):
    self.machine.log.info("TrogPy::CodeBase starting")

  def mode_stop(self, **kwargs):
    self.machine.log.info("TrogPy::CodeBase stopping")
