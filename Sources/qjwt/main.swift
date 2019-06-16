import Foundation
import ParkBench
import Pogging
import Guaka

let Qjwt_Version = "1.0.1"
let Qjwt_Build = 2
let Qjwt_DateString = "2019-06-16"

//#if QDURINGDEVELOPMENT
let Debug_QDURINGDEVELOPMENT = true
//#else
//let Debug_QDURINGDEVELOPMENT = false
//#endif

let debug_dodoFeatures = Debug_QDURINGDEVELOPMENT && true
PoggingSetup.setupLogMan(useNsLog: false, developmentMode: Debug_QDURINGDEVELOPMENT)

print("Qjwt V\(Qjwt_Version) (Build \(Qjwt_Build), \(Qjwt_DateString)).")
LogMan.pog(.debug, "Qjwt Started, Home is \(NSHomeDirectory().q)")

let directLogger: ParkBenchLogger = {
	let l = ParkBenchLogger(identifier: "TheQjwtLogger")

	// --------------------------------------------------------------------------------
	// setup file logger to file in "Application Support/<BundleId>/logs/<identifier>.log"
	// --------------------------------------------------------------------------------

	let logFilesPath = Pascription(.home, ".Qjwt/logs").vendUrl(createDirIfNonExistant: true)
	let url = logFilesPath.appendingPathComponents(l.identifier).appendingPathExtension("log")

	let fileDestination = FileDestination(writeToFile: url, identifier: "parkbench file logger to \(l.identifier).log", shouldAppend: true, flushAfterEachLine: true, level: .verbose).forced("Cannot open log file \(url.path.q)")
	fileDestination.configureLogLine(messagePrefix: false, date: false, logIdentifier: false, level: false, tag: false, threadName: false, filenameAndLineNumber: false, functionName: false)
	l.add(destination: fileDestination)

	return l
}()

LogMan.add(directLogger: directLogger, minimumLevel: .verbose)
LogMan.direct(id: "ArtworkUrls", .debug, "neustart")

for str in LogMan.renderFileLoggerUrls() {
	print("🗂 Logfile \(str.q)")
}

// --------------------------------------------------------------------------------
// setup root command
// --------------------------------------------------------------------------------

let rootCommandMaster = Command(usage: "\(CommandLine.arguments.first!)", shortMessage: "No root command") { command, _, _ in
	print(command.helpMessage)
}

// --------------------------------------------------------------------------------
// execute
// --------------------------------------------------------------------------------

rootCommandMaster.add(subCommands: Commands().createCommands())
rootCommandMaster.execute()
