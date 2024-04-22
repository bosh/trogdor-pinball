@tool
class_name MPFSceneBase
extends Control

var priority: int = 0
var context: String
var key: String
var _expirations: Dictionary = {}

func initialize(name: String, settings: Dictionary, context: String, priority: int = 0, kwargs: Dictionary = {}) -> void:
    # The node name attribute is the name of the root node, which could be
    # anything or case-sensitive. Set an explicit key instead, using the name.
    self.key = settings["key"] if settings.get("key") else name
    self.priority = settings['priority'] + priority if settings['priority'] else priority
    self.context = settings["custom_context"] if settings.get('custom_context') else context

func process_action(child_name: String, children: Array, action: String, settings: Dictionary, context: String, priority: int = 0, kwargs: Dictionary = {}) -> void:
    var child: MPFSceneBase
    var key = settings['key'] if settings.get('key') else child_name
    for c in children:
        if c.key == key:
            child = c
            break
    match action:
        "play":
            if not child:
                child = self.action_play(child_name, settings, context, priority, kwargs)
        "queue", "queue_first", "queue_immediate":
            self.action_queue(action, child_name, settings, context, priority, kwargs)
            child = null
        "remove":
            if child:
                self.action_remove(child)
        "update":
            if child:
                child.action_update(settings, kwargs)
        "method":
            if child and child.has_method(settings.method):
                var callable = Callable(child, settings.method)
                callable.call(settings, kwargs)
    if child and settings.expire:
        self._create_expire(child, settings.expire)

func action_play(child_name: String, settings: Dictionary, context: String, priority: int = 0, kwargs: Dictionary = {}):
    assert(false, "Method 'action_play' must be overridden in child classes of MPFSceneBase")

func action_remove(widget: Node) -> void:
    assert(false, "Method 'action_remove' must be overridden in child classes of MPFSceneBase")

func action_queue(action: String, slide_name: String, settings: Dictionary, context: String, priority: int = 0, kwargs: Dictionary = {}):
    assert(false, "Method 'action_queue' must be overridden in child classes of MPFSceneBase")

func action_update(settings: Dictionary, kwargs: Dictionary = {}):
    pass

func _create_expire(child: MPFSceneBase, expiration_secs: float) -> void:
    # If there is already a timer for this child to expire, reset it
    if self._expirations.has(child.key):
        self._expirations[child.key].start(expiration_secs)
        return

    var timer = Timer.new()
    timer.wait_time = expiration_secs
    timer.one_shot = true
    timer.autostart = true
    timer.timeout.connect(self._on_expire.bind(child, timer))
    self.add_child(timer)
    self._expirations[child.key] = timer

func _on_expire(child, timer: Timer) -> void:
    self._expirations.erase(child.key)
    self.remove_child(timer)
    timer.queue_free()
    self.action_remove(child)
