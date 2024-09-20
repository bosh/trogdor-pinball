from mpf.core.custom_code import CustomCode


class Core(CustomCode):
  def on_load(self):
    self.machine.log.info("Trogpy Core loaded!")
