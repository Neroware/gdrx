const MAX_SIZE = 9223372036854775807

## Represents an un-defined state
class NotSet extends Comparable:
	func eq(other) -> bool:
		return other is self

## An infinite iterable sequence
class InfiniteIterator extends IterableBase:
	var _infval
	var _counter : int
	func _init(infval = GDRx.util.GetNotSet()):
		self._infval = infval
		self._counter = 0
	func next() -> Variant:
		self._counter += 1
		if not self._infval is GDRx.util.NotSet:
			return self._infval
		return self._counter

## An infinite iterable sequence that stops when a condition is not met anymore.
class WhileIterator extends IterableBase:
	var _it : IterableBase
	var _cond : Callable
	func _init(it : IterableBase, cond : Callable):
		self._it = it
		self._cond = cond
	func next() -> Variant:
		if not self._cond.call():
			return End.new()
		return self._it.next()

## Creates an ArrayIterator
func Iter(x : Array, start : int = 0, end : int = -1) -> IterableBase:
	return ArrayIterator.new(x, start, end)

## Creates an InfiniteIterator
func Infinite(infval = GDRx.util.GetNotSet()) -> IterableBase:
	return InfiniteIterator.new(infval)

## Creates a WhileIterator
func TakeWhile(cond : Callable, it : IterableBase) -> IterableBase:
	return WhileIterator.new(it, cond)

## Creates an instance of NotSet
func GetNotSet() -> NotSet:
	return NotSet.new()

func AddRef(xs : Observable, r : RefCountDisposable) -> Observable:
	var subscribe = func(
		observer : ObserverBase,
		scheduler : SchedulerBase = null
	) -> DisposableBase:
		return CompositeDisposable.new([
			r.disposable(), 
			xs.subscribe(observer)
		])
	
	return Observable.new(subscribe)
