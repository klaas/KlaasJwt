import Foundation
import ParkBench
import Pogging

class PoggingSetup {
	struct LogTags {
		static var Master = LogTag(code: "Master", color: .lightRed, prefix: nil, minimumLevel: .debug)
		static var Performance = LogTag(code: "Performance", color: .lightBlue, prefix: "🕰", minimumLevel: .debug)
		
		static let allLogTags: [LogTag] = [
			LogTags.Master,
			LogTags.Performance,
			]
	}
	
	// MARK: - 🔴🔴🔴🔴🔴 logger 🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴
	
	private static var mainLogger: ParkBenchLogger!
	private static var essentialsFileLogger: ParkBenchLogger?
	
	// MARK: - 🔴🔴🔴🔴🔴 constants 🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴
	
	static var essentialsLogFilePath = Pascription(.temp, "logs").vendUrl(createDirIfNonExistant: true).appendingPathComponents("LogManEssentials.log")
	//		let logFilesPath = Pascription(.applicationSupport_MainBundleIdentifier, "logs").vendUrl(fm:fm, createDirIfNonExistant: true)
	
	// MARK: - 🔴🔴🔴🔴🔴 setup 🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴
	
	class func setupLogMan(useNsLog: Bool, developmentMode: Bool) {
		if developmentMode {
			self.essentialsLogFilePath = Pascription(.documents, "logs").vendUrl(createDirIfNonExistant: true).appendingPathComponents("LogManEssentials.log")
		}
		
		// --------------------------------------------------------------------------------
		// assert when called multiple times
		// --------------------------------------------------------------------------------
		
		struct Statics {
			static var Flag_IsSetup = false
		}
		assert(Statics.Flag_IsSetup == false, "❌ ❌ ❌  Assert Logging Flag_IsSetup")
		
		mainLogger = PoggingSetup._createMainLogManLogger(useNsLog: useNsLog)
		essentialsFileLogger = PoggingSetup._createEssentialsLogManFileLogger(developmentMode: developmentMode)
		
		LogMan.setup(mainLogger: mainLogger, essentialsLogger: essentialsFileLogger, logTags: LogTags.allLogTags, masterMinimumLevel: developmentMode ? .debug : .info)
		
		// --------------------------------------------------------------------------------
		// mark as setup
		// --------------------------------------------------------------------------------
		
		Statics.Flag_IsSetup = true
	}
	
	// MARK: - 🔴🔴🔴🔴🔴 factory methods 🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴
	
	/// Creates the main logger. The main logger logs with print() or NSLog() and on macOS to a file
	fileprivate class func _createMainLogManLogger(useNsLog: Bool = false) -> ParkBenchLogger {
		let res = ParkBenchLogger(identifier: "LogMan")
		
		do {
			// --------------------------------------------------------------------------------
			// NSLog logging vs. console logging
			// --------------------------------------------------------------------------------
			
			let destination: BaseDestination
			if useNsLog {
				destination = NSLogDestination(level: .debug)
			} else {
				let cd = ConsoleDestination(level: .debug)
				cd.logQueue = DispatchQueue(label: "ConsoleLogQueue", qos: .userInitiated)
				destination = cd
			}
			
			destination.outputLevel = .debug
			destination.showThreadName = true
			destination.showLevel = false
			destination.showTag = false
			destination.showLogIdentifier = false
			destination.showDate = false
			destination.showFunctionName = true
			
			res.add(destination: destination)
		}
		
		// --------------------------------------------------------------------------------
		// macOS ->
		// setup file logger to file in "Application Support/<BundleId>/logs/<identifier>.log"
		// --------------------------------------------------------------------------------
		
		#if os(macOS)
		let fm = FileManager.default
		let logFilesPath = Pascription(.home, ".qam").vendUrl(fm: fm, createDirIfNonExistant: true)
		let fileUrl = logFilesPath.appendingPathComponents(res.identifier).appendingPathExtension("log")
		
		let fileDestination = FileDestination(writeToFile: fileUrl, identifier: "eu.parkbench.MisterMap.macOS", shouldAppend: true)!
		fileDestination.outputLevel = .debug
		
		fileDestination.showDate = true
		fileDestination.showLogIdentifier = false
		fileDestination.showLevel = false
		fileDestination.showTag = true
		fileDestination.showThreadName = false
		fileDestination.showFilenameAndLineNumber = false
		fileDestination.showFunctionName = true
		
		res.add(destination: fileDestination)
		#endif
		
		// --------------------------------------------------------------------------------
		// ios -> shorted date format
		// --------------------------------------------------------------------------------
		
		#if os(iOS) || os(tvOS)
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "HH:mm"
		dateFormatter.locale = Locale.current
		res.dateFormatter = dateFormatter
		#endif
		
		return res
	}
	
	/// pure file logger
	fileprivate class func _createEssentialsLogManFileLogger(developmentMode: Bool) -> ParkBenchLogger {
		let res = ParkBenchLogger(identifier: "LogManEssentials")
		
		// --------------------------------------------------------------------------------
		// file destination
		// --------------------------------------------------------------------------------
		
		let fileDestination = FileDestination(writeToFile: essentialsLogFilePath, identifier: "eu.parkbench.LogMan.Essentials.FileLogger", shouldAppend: developmentMode)!
		fileDestination.outputLevel = .debug
		
		fileDestination.showDate = true
		fileDestination.showLogIdentifier = false
		fileDestination.showLevel = false
		fileDestination.showTag = true
		fileDestination.showThreadName = false
		fileDestination.showFilenameAndLineNumber = true
		fileDestination.showFunctionName = true
		
		res.add(destination: fileDestination)
		
		return res
	}
}
