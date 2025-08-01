from mpf.core.async_mode import AsyncMode
from mpf.core.utility_functions import Util

class Minigame(AsyncMode):
  __slots__ = ['_on_left', '_on_right', '_on_start']

  def mode_init(self):
    try:
        super().mode_init()
    except AssertionError:
        pass
    self.machine.log.info("TrogPy::Minigame initialized")

  def mode_start(self, **kwargs):
    self.machine.log.info("TrogPy::Minigame starting")

  def mode_stop(self, **kwargs):
    self.machine.log.info("TrogPy::Minigame stopping")

  async def _get_key(self):
    futures = {
      self.machine.events.wait_for_any_event(["s_left_flipper_active"]): "LEFT",
      self.machine.events.wait_for_any_event(["s_right_flipper_active"]): "RIGHT",
      self.machine.events.wait_for_any_event(["s_start_active"]): "START"
    }
    return await Util.race(futures)

  async def _run(self):
    await self._minigame_mode_play()

  async def _minigame_mode_play(self):
      while True:
          key = await self._get_key()
          if key:
              self.machine.events.post("minigame_action", action=key)
