package test;

import haxe.Timer;

using hx.strings.Strings;
import utest.Assert;

import hiss.HTypes;
import hiss.CCInterp;
import hiss.HissTools;
using hiss.HissTools;
import hiss.StaticFiles;

class HissTestCase extends utest.Test {

    var interp: CCInterp;
    var file: String;

    var functionsTested: Map<String, Bool> = [];
    var ignoreFunctions: Array<String> = [];

    public function new(hissFile: String, ?ignoreFunctions: Array<String>) {
        super();
        file = hissFile;

        // Some functions just don't wanna be tested
        if (ignoreFunctions != null) this.ignoreFunctions = ignoreFunctions;
    }

    function hissTest(args: HValue, env: HValue, cc: Continuation) {
        var fun = args.first().symbolName();
        var assertions = args.rest();
        var env = List([Dict([])]);
        for (ass in assertions.toList()) {
            var failureMessage = 'Failure testing $fun: ${ass.toPrint()} evaluated to: ';
            var errorMessage = 'Error testing $fun: ${ass.toPrint()}: ';
            try {
                interp.eval(ass, env, (val) -> {
                    Assert.isTrue(val.truthy(), failureMessage + val.toPrint());
                });
            } catch (err: Dynamic) {
                Assert.fail(errorMessage + err.toString());
            }
        }
        
        functionsTested[fun] = true;
    }

    function testFile() {
        trace("Measuring time to construct the Hiss environment:");
        interp = Timer.measure(function () { return new CCInterp(); });

        interp.globals.put("test", SpecialForm(hissTest));

        for (f in ignoreFunctions) {
            functionsTested[f] = true;
        }

        trace("Measuring time taken to run the unit tests:");

        Timer.measure(function() {
            interp.load(file);
            trace("Total time to run tests:");
        });

        for (v => val in interp.globals.toDict()) {
            switch (val) {
                case Function(_, _) | SpecialForm(_) | Macro(_):
                    if (!functionsTested.exists(v)) functionsTested[v] = false;
                default:
            }
        }

        for (fun => tested in functionsTested) {
            Assert.isTrue(tested, 'Failure: $fun was never tested');
        }
    }

}