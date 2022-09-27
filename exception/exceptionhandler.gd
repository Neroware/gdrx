class_name ExceptionHandler

## Handles raised Exceptions
##
## Objects of type [ThrowableBase] are handled by this type's singleton

var _try_catch_stack : Array[TryCatch]
var _has_failed : Dictionary

func _init(verify_ = null):
	if not verify_ == "GDRx":
		push_warning("Warning! Must only instance Scheduler from GDRx singleton!")
	self._try_catch_stack = []
	self._has_failed = {}

static func singleton() -> ExceptionHandler:
	return GDRx.ExceptionHandler_

func run(stmt : TryCatch) -> bool:
	self._has_failed[stmt] = false
	
	self._try_catch_stack.push_back(stmt)
	stmt.risky_code.call()
	self._try_catch_stack.pop_back()
	
	var failed = self._has_failed[stmt]
	self._has_failed.erase(stmt)
	return failed

func raise(exc : ThrowableBase, default = null) -> Variant:
	var handler : Callable = GDRx.basic.default_crash
	
	if self._try_catch_stack.is_empty():
		handler.call(exc)
		return default
	
	handler = GDRx.basic.noop
	
	var stmt : TryCatch = self._try_catch_stack.pop_back()
	self._has_failed[stmt] = true
	for type in exc.tags():
		if type in stmt.caught_types:
			handler = stmt.caught_types[type]
			break
	
	handler.call(exc)
	self._try_catch_stack.push_back(stmt)
	return default
