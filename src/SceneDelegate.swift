
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }

        search(shortcutItem: connectionOptions.shortcutItem, window: window)

    }

    func sceneDidDisconnect(_ scene: UIScene) { not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {ere paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {s (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) { entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {tate.
    }


}

extension SceneDelegate {
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void){
        search(shortcutItem: shortcutItem, window: windowScene.windows.first)
    }
}

private extension SceneDelegate {
    func search(shortcutItem: UIApplicationShortcutItem?, window: UIWindow?) {
        guard
            let shortcutItem = shortcutItem,
            shortcutItem.type == "com.FastMDb.search",
            let nav = window?.rootViewController as? UINavigationController,
            let main = nav.viewControllers.last as? MainViewController else { return }

        main.activateSearch()
    }
}
