package;

import haxe.ds.Either;

enum HAtom {
 Nil;
 Int(value: Int);
 Double(value: Float);
 Symbol(name: String);
 String(value: String);
}

class HCons {
 var first: HValue;
 var rest: HValue;

 public function new(first: HValue, rest: HValue) {
	this.first = first;
	this.rest = rest;
 }
}

enum HValue {
 Atom(a: HAtom);
 Cons(c: HCons);
}