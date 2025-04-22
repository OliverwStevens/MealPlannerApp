# Pin npm packages by running ./bin/importmap
# config/importmap.rb
pin "application", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "@zxing/library", to: "zxing-umd.min.js", preload: true
pin "barcode_scanner", to: "barcode_scanner.js"
pin "ts-custom-error" # @3.3.1
