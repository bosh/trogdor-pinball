from mpf.modes.carousel.code.carousel import Carousel

class MusicSelection(Carousel):
  __slots__ = []

  def mode_init(self):
    try:
        super().mode_init()
    except AssertionError:
        pass
    self.machine.log.info("TrogPy::MusicSelection initialized")

  def mode_start(self, **kwargs):
    self.machine.log.info("TrogPy::MusicSelection starting")

    if self._all_items:
      super().mode_start(**kwargs) #Carousel base class
    else:
      self.machine.log.error("TrogPy::MusicSelection no items!!! X.X")

    self.select_item_based_on_state_machine()

  def mode_stop(self, **kwargs):
    self.machine.log.info("TrogPy::MusicSelection stopping")

  def select_item_based_on_state_machine(self):
    initial_item = self.machine.state_machines['music_jukebox'].state
    self._highlighted_item_index = int(initial_item.split("_")[-1]) - 1
    self.machine.log.info(f"TrogPy::MusicSelection initial highlighting item {initial_item}")
    self.machine.events.post('carousel_item_highlighted', carousel=self.name, direction='forward', item=initial_item)
