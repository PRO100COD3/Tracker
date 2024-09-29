//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Вадим Дзюба on 29.09.2024.
//

import Foundation
import AppMetricaCore


typealias AnalyticsEventParam = [AnyHashable: Any]
enum AnalyticsService {
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "01b25cda-d1c8-4232-9831-d5e439146d05") else {
            assertionFailure("Ошибка инициализации Yandex.Metrica")
            return
        }
        AppMetrica.activate(with: configuration)
    }
    static func report(event: String, params: AnalyticsEventParam) {
        AppMetrica.reportEvent(name: event, parameters: params) { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        }
    }
}
