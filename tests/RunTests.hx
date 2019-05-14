package ;

import haxe.io.BytesData;
import haxe.ds.ReadOnlyArray;
import tink.unit.*;
import tink.testrunner.*;
import exp.fsm.*;

using tink.CoreApi;

@:asserts
class RunTests {

	static function main() {
		Runner.run(TestBatch.make([
			new RunTests(),
		])).handle(Runner.exit);
	}
	
	function new() {}
	
	public function test() {
		
		var logs = [];
		function log(name:String, event:String) logs.push('$name:$event');
		var fsm = StateMachine.create([
			new TestState('foo', ['bar'], log),
			new TestState('bar', ['baz'], log),
			new TestState('baz', ['foo'], log),
		]);
		asserts.assert(fsm.current.key == 'foo');
		asserts.assert(fsm.canTransitTo('bar'));
		asserts.assert(!fsm.canTransitTo('baz'));
		
		asserts.assert(!fsm.transit('baz').isSuccess());
		asserts.assert(fsm.current.key == 'foo');
		
		asserts.assert(fsm.transit('bar').isSuccess());
		asserts.assert(fsm.current.key == 'bar');
		asserts.assert(fsm.canTransitTo('baz'));
		asserts.assert(!fsm.canTransitTo('foo'));
		
		asserts.assert(fsm.transit('baz').isSuccess());
		asserts.assert(fsm.current.key == 'baz');
		asserts.assert(fsm.canTransitTo('foo'));
		asserts.assert(!fsm.canTransitTo('bar'));
		
		asserts.assert(logs.join(',') == 'foo:enter,foo:exit,bar:enter,bar:exit,baz:enter');
		
		return asserts.done();
	}
	
}

class TestState implements State<String> {
	public final key:String;
	final next:ReadOnlyArray<String>;
	final log:String->String->Void;
	public function new(key, next, log) {
		this.key = key;
		this.next = next;
		this.log = log;
	}
	public function canTransitTo(key:String) return next.indexOf(key) != -1;
	public function onActivate():Void log(key, 'enter');
	public function onDeactivate():Void log(key, 'exit');
}