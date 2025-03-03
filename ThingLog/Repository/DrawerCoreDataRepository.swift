//
//  DrawerCoreDataRepository.swift
//  ThingLog
//
//  Created by hyunsu on 2021/10/29.
//

import CoreData
import Foundation

/// Drawer들을 가져오고 업데이트를 할 수 있는 객체를 정의한 프로토콜이다.
protocol DrawerRepositoryable {
    /// Drawe들을 가져오는 역할을 합니다.
    func fetchDrawers(_ completion: (([Drawerable]?) -> Void)?)
    
    /// 대표 진열장 물건을 찾도록 합니다. 없는 경우는 nil로 반환합니다.
    func fetchRepresentative() -> Drawerable?
    
    /// 수학의 정석을 업데이트 합니다. `SceneDelegate` - `sceneDidBecomeActive`에 추가한다.
    func updateMath()
    
    /// 문구세트를 업데이트합니다. `SceneDelegate` - `sceneDidBecomeActive`에 추가한다.
    func updateStationery()
    
    /// 인의예지상을 업데이트합니다. `포토카드` 버튼 들어가는 로직에 추가한다.
    func updateRightAward()
    
    /// 드래곤볼을 업데이트 합니다. `PostErpository`의 `create`, `update`메소드에 추가한다.
    func updateDragonBall(rating: Int16)
    
    /// 장바구니를 업데이트 합니다. `사고싶다` 버튼이 들어가는 로직에 추가한다.
    func updateBasket()
    
    /// VIP를 업데이트 합니다. `PostErpository`의 `create`, `update`메소드에 추가한다.
    func updateVIP(by money: Int)
    
    /// 대표 진열장 물건을 업데이트 합니다. `SelectingDrawerViewController`의 `대표설정`버튼 들어가는 로직에 추가한다.
    func updateRepresentative(drawer: Drawerable?)
    
    /// 진열장 아이템을 새로 획득한 경우에 이벤트를 가져옵니다.
    func isNewEvent(_ completion: @escaping ((Bool) -> Void))
    
    /// 새로 획득한 진열장 아이템의 이벤트를 확인처리합니다.
    func completeNewEvent()
    
    /// 파라미터로 들어온 아이템의 획득 여부를 반환합니다.
    func hasItem(for item: Drawerable, _ completion: @escaping((Bool)) -> Void)
}

/// `CoreData`를 이용하여 `Drawer`를 가져오고 업데이트 하는 객체다.
class DrawerCoreDataRepository: DrawerRepositoryable {
    private let coreDataStack: CoreDataStack
    var defaultDrawers: [Drawerable]?
    var keyValueStorage: KeyValueStoragable = UserDefaultKeyValueStorage.shared
    
    /// 초기화를 진행하는데, fetchDrawers가 필요한 경우는 `DefaultDrawerModle`의 `drawers` 프로퍼티를 넣는다. 그렇지 않은 경우는 넘어간다. 불필요하게 defaultDrawers의 메모리를 가지고 있을 필요는 없기 때문이다.
    init(coreDataStack: CoreDataStack = CoreDataStack.shared,
         defaultDrawers: [Drawerable]? = nil ) {
        self.coreDataStack = coreDataStack
        self.defaultDrawers = defaultDrawers
    }
    
    // MARK: - Fetch
    func fetchDrawers(_ completion: (([Drawerable]?) -> Void)?) {
        // 먼저 CoreData에 없는 Drawer들을 저장하고
        setupDrawers()
        
        let request: NSFetchRequest<DrawerEntity> = DrawerEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false)]
        do {
            completion?(try coreDataStack.mainContext.fetch(request))
        } catch {
            completion?(nil)
        }
    }
    
    func fetchRepresentative() -> Drawerable? {
        /// 대표 진열장을 선정한 경우 찾고, 없다면 nil을 반환합니다.
        guard let representative: String = keyValueStorage.string(forKey: KeyStoreName.representativeDrawer.name) else {
            return nil
        }
        
        let request: NSFetchRequest<DrawerEntity> = DrawerEntity.fetchRequest()
        request.predicate = NSPredicate(format: "imageName == %@", representative)
        do {
            if let drawer: DrawerEntity = try coreDataStack.mainContext.fetch(request).first {
                return drawer
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    // MARK: - Update
    func updateRightAward() {
        // 포토카드로 선물 인사 보낸경우
        acquireDrawer(by: SwiftGenDrawerList.rightAward.imageName)
    }
    
    func updateMath() {
        // 수학의 정석 업데이트
        updateLoginCount(currentDate: Date())
        
        let loginCount: Int64 = keyValueStorage.int(forKey: KeyStoreName.userLoginCount.name)
        
        if loginCount >= 3 {
            acquireDrawer(by: SwiftGenDrawerList.math.imageName)
        }
    }
    
    func updateStationery() {
        // 30일 접속 문구세트 업데이트
        updateLoginCount(currentDate: Date())
        
        let loginCount: Int64 = keyValueStorage.int(forKey: KeyStoreName.userLoginCount.name)
        
        if loginCount >= 30 {
            acquireDrawer(by: SwiftGenDrawerList.stationery.imageName)
        }
    }
    
    func updateRepresentative(drawer: Drawerable?) {
        if let drawer: Drawerable = drawer {
            keyValueStorage.set(drawer.imageName, forKey: KeyStoreName.representativeDrawer.name)
        } else {
            keyValueStorage.removeObject(forKey: KeyStoreName.representativeDrawer.name)
        }
    }
    
    func updateBasket() {
        acquireDrawer(by: SwiftGenDrawerList.basket.imageName)
    }
    
    func updateDragonBall(rating: Int16) {
        // 만족도 0은 만족도 미선택이므로, return 한다.
        if rating == 0 {
            return
        }
        
        // 만족도 1-5개 기록 모으기
        // 배열을 이용하여 중복값이 없는 경우에만 추가하여, 판별한다.
        var dragonBallArray: [Int16] = keyValueStorage.array(forKey: KeyStoreName.dragonBallArray.name) as? [Int16] ?? []
        if dragonBallArray.contains(rating) == false {
            dragonBallArray.append(rating)
        }
        keyValueStorage.set(dragonBallArray, forKey: KeyStoreName.dragonBallArray.name)
        
        if dragonBallArray.count == 5 {
            acquireDrawer(by: SwiftGenDrawerList.dragonball.imageName)
        }
    }
    
    func updateVIP(by money: Int) {
        if money >= 1_000_000 {
            acquireDrawer(by: SwiftGenDrawerList.blackCard.imageName)
        }
    }
    
    func isNewEvent(_ completion: @escaping ((Bool) -> Void)) {
        let isNewEvent: Bool = keyValueStorage.bool(forKey: KeyStoreName.isNewEvent.name)
        completion(isNewEvent)
    }
    
    func completeNewEvent() {
        // 획득이벤트를 확인처리하고,
        keyValueStorage.set(false, forKey: KeyStoreName.isNewEvent.name)

        // 진열장아이템들을 모두 확인처리한다.
        fetchDrawers { drawers in
            guard let drawers = drawers else { return }
            drawers.forEach {
                let request: NSFetchRequest<DrawerEntity> = DrawerEntity.fetchRequest()
                request.predicate = NSPredicate(format: "imageName == %@", $0.imageName ?? "")
                do {
                    if let drawer: DrawerEntity = try self.coreDataStack.mainContext.fetch(request).first {
                        drawer.isNewDrawer = false
                        // 새로운 진열장 아이템을 획득 했다 이벤트 발생.
                        self.keyValueStorage.set(false, forKey: KeyStoreName.isNewEvent.name)
                        try self.coreDataStack.mainContext.save()
                    } else {
                        return
                    }
                } catch {
                    return
                }
            }
        }
    }
    
    /// 파라미터로 들어온 아이템의 획득 여부를 반환합니다.
    func hasItem(for item: Drawerable, _ completion: @escaping((Bool)) -> Void) {
        fetchDrawers { drawers in
            if let drawers: [Drawerable] = drawers,
               let index: Int = drawers.firstIndex(where: { $0.imageName == item.imageName }) {
                completion(drawers[index].isAcquired)
            }
        }
    }
}

extension DrawerCoreDataRepository {
    /// CoreData를 사용하는 경우 미리 필요한 Drawer정보들이 없는 경우나 변경된 정보를 반영하기 위해 저장한다.
    private func setupDrawers() {
        defaultDrawers?.forEach {
            let request: NSFetchRequest<DrawerEntity> = DrawerEntity.fetchRequest()
            request.predicate = NSPredicate(format: "imageName == %@", $0.imageName ?? "")
            do {
                let drawers: [DrawerEntity] = try coreDataStack.mainContext.fetch(request)
                var drawerEntity: DrawerEntity
                
                if let drawer: DrawerEntity = drawers.first {
                    drawerEntity = drawer
                } else {
                    // 새로 만드는 경우에 초기화해야하는 부분.
                    drawerEntity = DrawerEntity(context: coreDataStack.mainContext)
                    drawerEntity.isAcquired = $0.isAcquired
                    drawerEntity.isNewDrawer = $0.isNewDrawer
                }
                
                drawerEntity.identifier = UUID()
                drawerEntity.imageName = $0.imageName
                drawerEntity.title = $0.title
                drawerEntity.subTitle = $0.subTitle
                drawerEntity.information = $0.information
                
                try coreDataStack.mainContext.save()
            } catch {
                return
            }
        }
    }
    
    /// 특정 imageName을 가진 Drawer를 찾아, 획득한걸로 변경한다.
    private func acquireDrawer(by imageName: String) {
        let request: NSFetchRequest<DrawerEntity> = DrawerEntity.fetchRequest()
        request.predicate = NSPredicate(format: "imageName == %@", imageName)
        do {
            if let drawer: DrawerEntity = try coreDataStack.mainContext.fetch(request).first {
                if drawer.isAcquired { return }
                drawer.isAcquired = true
                drawer.isNewDrawer = true
                // 새로운 진열장 아이템을 획득 했다 이벤트 발생.
                keyValueStorage.set(true, forKey: KeyStoreName.isNewEvent.name)
                try coreDataStack.mainContext.save()
            } else {
                return
            }
        } catch {
            return
        }
    }

    /// 현재 날짜를 기반으로 이전날짜와 비교하여 로그인 접속 횟수를 증가시킨다.  인자가 있는 이유는 테스트하기 위함이다.
    func updateLoginCount(currentDate: Date) {
        let changeStringClosure: (Date) -> String = {
            $0.toString(.year) +
                $0.toString(.month) +
                $0.toString(.day)
        }
        
        let nextLoginCount: Int64 = keyValueStorage.int(forKey: KeyStoreName.userLoginCount.name) + 1
        let currentDateString: String = changeStringClosure(currentDate)
        
        // 이전날짜String과 다른 경우에만 업데이트한다.
        let beforeDateString: String = keyValueStorage.string(forKey: KeyStoreName.userRecentLoginDate.name) ?? ""
        if beforeDateString != currentDateString {
            keyValueStorage.set(currentDateString, forKey: KeyStoreName.userRecentLoginDate.name)
            keyValueStorage.set(nextLoginCount, forKey: KeyStoreName.userLoginCount.name)
        }
    }
    
    func deleteAllDrawers() {
        keyValueStorage.removeObject(forKey: KeyStoreName.representativeDrawer.name)
        keyValueStorage.removeObject(forKey: KeyStoreName.dragonBallArray.name)
        keyValueStorage.set(false, forKey: KeyStoreName.isNewEvent.name)
        
        let request: NSFetchRequest<DrawerEntity> = DrawerEntity.fetchRequest()
        do {
            let drawer: [DrawerEntity] = try coreDataStack.mainContext.fetch(request)
            drawer.forEach {
                coreDataStack.mainContext.delete($0)
                self.setupDrawers()
            }
            try coreDataStack.mainContext.save()
        } catch {
            return
        }
    }
}
