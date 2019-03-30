import Cocoa
import FlutterMacOS

class MainWindow: NSWindow {
    
    @IBOutlet weak var flutterViewController: FLEViewController!
    
    override func awakeFromNib() {
        let assets = URL(fileURLWithPath: "flutter_assets", relativeTo: Bundle.main.resourceURL)
        let arguments: [String] = {
            #if !DEBUG
            return ["--disable-dart-asserts"]
            #else
            return []
            #endif
        }()
        self.flutterViewController.launchEngine(withAssetsPath: assets, commandLineArguments: arguments)
        super.awakeFromNib()
    }
}

