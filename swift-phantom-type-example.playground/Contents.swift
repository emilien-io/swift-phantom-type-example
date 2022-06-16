/**
 Structure that handles the conversion rate between USD and EUR.
 */
struct Converter {
    let USD_EUR = 0.95
    let EUR_USD = 1.05
    
    enum Conversion {
        case USD_EUR
        case EUR_USD
    }
    
    func getConversionRate(_ value: Double, with conversion: Conversion) -> Double {
        switch conversion {
        case .EUR_USD:
            return value * EUR_USD
        case .USD_EUR:
            return value * USD_EUR
        }
    }
}

/**
 Our phantom types which will be used to define (markers) the local currency of the bank account.
 */
enum Currency {
    enum Dollar {}
    enum Euro {}
}

/**
 Our `Account` depends on a generic `CurrencyType` type (`Currency.Dollar` / `Currency.Euro`).
 Based on its type, we will be able to use generic methods (eg. `transfer(_, _)`) or specific methods (eg. `transferEURUSD(_, _)`).
 
 Properties:
    - `converter` > Handles the conversion rate whenever an international transfer is made
    - `holder` > Account identity
    - `balance` > Amount of money the account holds
 */
class BankAccount<CurrencyType> {
    let converter: Converter = Converter()
    let holder: String
    var balance: Double
    
    init(_ name: String, withBalance value: Double) {
        holder = name
        balance = value
    }
    
    func transfer(_ value: Double, to receiver: BankAccount) {
        if value > balance {
            print("Account \(holder) - Insufficient balance ...")
            return
        }
        
        balance -= value
        receiver.balance += value
        print("Transfered \(value) from \(holder) (curr. balance $\(balance)) to \(receiver.holder) (curr. balance $\(receiver.balance))")
    }
}

/**
 Thanks to phantom type, we are able to define type-specific methods in addition of generic ones.
 We also add a type-check at compile time for the sender & `receiver` accounts (from USD to EUR in the following section).
 Here, we allow an USD bank account to transfer money to an EUR bank account after converting the value.
 */
extension BankAccount where CurrencyType == Currency.Dollar {
    func transferUSDEUR(_ value: Double, to receiver: BankAccount<Currency.Euro>) {
        if value > balance {
            print("Account \(holder) - Insufficient balance ...")
            return
        }
        
        balance -= value
        let exchangedValue = converter.getConversionRate(value, with: .USD_EUR)
        receiver.balance += exchangedValue
        
        // Do additionnal specific management to the currency / country
        
        print("Transfered $\(value) (\(exchangedValue)€) from \(holder) (curr. balance $\(balance)) to \(receiver.holder) (curr. balance \(receiver.balance)€)")
    }
}

extension BankAccount where CurrencyType == Currency.Euro {
    func transferEURUSD(_ value: Double, to receiver: BankAccount<Currency.Dollar>) {
        if value > balance {
            print("Account \(holder) - Insufficient balance ...")
            return
        }
        
        balance -= value
        let exchangedValue = converter.getConversionRate(value, with: .EUR_USD)
        receiver.balance += exchangedValue
        
        // Do additionnal specific management to the currency / country
        
        print("Transfered \(value)€ ($\(exchangedValue)) from \(holder) (curr. balance \(balance)€) to \(receiver.holder) (curr. balance $\(receiver.balance))")
    }
}

/**
 Tests starts here.
 */

let accountUSD1 = BankAccount<Currency.Dollar>("USD1", withBalance: 1000.0)
let accountUSD2 = BankAccount<Currency.Dollar>("USD2", withBalance: 1000.0)
let accountEUR1 = BankAccount<Currency.Euro>("EUR1", withBalance: 1000.0)

accountUSD1.transfer(200, to: accountUSD2)
//accountUSD1.transfer(200, to: accountEUR1)
// ^- This line won't compile since the `transfer(_, _)`
//  method only works with accounts with the same `CurrencyType`

accountUSD1.transferUSDEUR(100, to: accountEUR1)
//accountUSD1.transferUSDEUR(100, to: accountUSD2)
// ^- This line won't compile since the `transferUSDEUR(_, _)`
//  method asks for a destination account in EUR

//accountUSD1.transferEURUSD(100, to: accountEUR1)
// ^- This line won't compile since the `transferEURUSD(_, _)`
//  method is only available for account in EUR
