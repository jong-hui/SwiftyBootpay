//
//  ViewController.swift
//  SwiftyBootpay
//
//  Created by ehowlsla on 10/30/2017.
//  Copyright (c) 2017 ehowlsla. All rights reserved.
//

import UIKit
import SwiftyBootpay

//MARK: ViewController Init
class ViewController: UIViewController {
    var vc: BootpayController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setUI()
        sendAnaylticsUserLogin() // 유저 로그인 시점에 호출
    }
    
    func setUI() {
        let btn = UIButton(type: .roundedRect)
        btn.frame = CGRect(x: 0, y:0, width: self.view.frame.width, height: self.view.frame.height)
        btn.setTitle("Request", for: .normal)
        btn.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
        self.view.addSubview(btn)
    }
    
    @objc func btnClick() {
        sendAnaylticsPageCall() // 페이지 유입(추적) 시점에 호출, 로그인 통신이 완료된 후에 호출해야 함
        presentBootpayController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


//MARK: Bootpay Event Handle
extension ViewController {
    func sendAnaylticsUserLogin() {
        BootpayAnalytics.sharedInstance.user.params {
            $0.id = "testUser" // user 고유 id 혹은 로그인 아이디
            $0.username = "홍길동" // user 이름
            $0.email = "testUser@gmail.com" // user email
            $0.gender = 1 // 1: 남자, 0: 여자
            $0.birth = "861014" // user 생년월일 앞자리
            $0.phone = "01012345678" // user 휴대폰 번호
            $0.area = "서울" //
        }
        BootpayAnalytics.sharedInstance.postLogin()
    }
    
    func sendAnaylticsPageCall() {
        BootpayAnalytics.sharedInstance.postCall(url: "item_list", // 페이지를 구분하는 주소
                                                 page_type: "아이템", // 페이지 유형
                                                 img_url: "", // 대표 상품 이미지 url
                                                 item_unique: "1", // 대표 상품의 고유 키
                                                 item_name: "철산동핫도그") // 대표 상품명
    }
    
    func presentBootpayController() {
        // 통계정보를 위해 사용되는 정보
        // 주문 정보에 담길 상품정보로 배열 형태로 add가 가능함
        let item = BootpayItem().params {
            $0.item_name = "B사 마스카라" // 주문정보에 담길 상품명
            $0.qty = 1 // 해당 상품의 주문 수량
            $0.unique = "123" // 해당 상품의 고유 키
            $0.price = 1000 // 상품의 가격
        }
        
        // 커스텀 변수로, 서버에서 해당 값을 그대로 리턴 받음
        let customParams: [String: String] = [
            "callbackParam1": "value12",
            "callbackParam2": "value34",
            "callbackParam3": "value56",
            "callbackParam4": "value78",
            ]
        
        vc = BootpayController()
        
        // 주문정보 - 실제 결제창에 반영되는 정보
        vc.params {
            $0.price = 1000 // 결제할 금액
            $0.name = "블링블링 마스카라" // 결제할 상품명
            $0.order_id = "1234" // 결제 고유번호
            $0.params = customParams // 커스텀 변수
            $0.method = "card" // 결제수단
            $0.pg = "danal" // 결제할 PG사
            $0.sendable = self // 이벤트를 처리할 protocol receiver
        }
        vc.addItem(item: item) //배열 가능
        
        self.present(vc, animated: true, completion: nil) // bootpay controller 호출
    }
}


//MARK: Bootpay Callback Protocol
extension ViewController: BootpayRequestProtocol {
    // 에러가 났을때 호출되는 부분
    func onError(data: [String: Any]) {
        print(data)
        vc.dismiss() // 결제창 종료
    }
    
    // 결제가 진행되기 바로 직전 호출되는 함수로, 주로 재고처리 등의 로직이 수행
    func onConfirm(data: [String: Any]) {
        print(data)
        
        var iWantPay = true
        if iWantPay == true {
            vc.transactionConfirm(data: data) // 결제 승인
        } else {
            vc.dismiss() // 결제창 종료
        }
    }
    
    // 결제 취소시 호출
    func onCancel(data: [String: Any]) {
        print(data)
        vc.dismiss()
    }
    
    // 결제완료시 호출
    // 아이템 지급 등 데이터 동기화 로직을 수행합니다
    func onDone(data: [String: Any]) {
        print(data)
        vc.dismiss()
    }
}
