# Phantom types

> Ambiguous data is arguably one of the most common sources of bugs and problems within apps in general. While Swift helps us avoid many sources of ambiguity through its strong type system and thorough compiler — whenever we’re unable to create a compile-time guarantee that a given piece of data will always match our requirements, there’s always a risk that we’ll end up in an ambiguous or unpredictable state.
>
>This week, let’s take a look at a technique that can let us leverage Swift’s type system to perform even more kinds of data validation at compile time — removing more potential sources of ambiguity, and helping us preserve type safety throughout our code base — by using  _phantom types_.
*(John Sundell, on [swiftbysundell](https://www.swiftbysundell.com/articles/phantom-types-in-swift/))*

In this project, we are trying to demonstrate the power of **phantom types**.
Based on a class custom type, we show how we could handle generic bank transfers to local account (USD to USD) and specific transfers (USD to EUR) while adding type-checks at compile time.

- `class BankAccount<CurrencyType>`
	> Our main class is instantiated using a `CurrencyType` and for that we will be using an enum containing enums but without cases (see below). This is what we call phantom type, instead of creating a value that would differentiate your objects, you use a phantom type that will not be instantiated be used as a marker.

```
enum Currency {
    enum Dollar {}
    enum Euro {}
}
```

This way you can create many `BankAccount` that will conform to different APIs based on their custom types.

> Note: This code has for only purpose of being an example. You could easily make the whole thing more generic by checking the type of your object during a transfer, for example `if self is BankAccount<Currency.Dollar>`.

# Going further

In addition, you can manage the behaviour of your object with extensions based on its type.
For example, you can say that an USD account trying to transfer money to an external account that the destination has to be in EUR (for example because exchange in other currency is not handled yet).

```
extension BankAccount where CurrencyType == Currency.Dollar {
	func transferUSDEUR(_ value: Double, to receiver: BankAccount<Currency.Euro>) {
		...
	}
}
```

# Example

```
let accountUSD1 = BankAccount<Currency.Dollar>("USD1", withBalance: 1000.0)
let accountUSD2 = BankAccount<Currency.Dollar>("USD2", withBalance: 1000.0)
let accountEUR1 = BankAccount<Currency.Euro>("EUR1", withBalance: 1000.0)

accountUSD1.transfer(200, to: accountUSD2)
accountUSD1.transfer(200, to: accountEUR1)
// ^- This line won't compile since the `transfer(_, _)`
//  method only works with accounts with the same `CurrencyType`

accountUSD1.transferUSDEUR(100, to: accountEUR1)
accountUSD1.transferUSDEUR(100, to: accountUSD2)
// ^- This line won't compile since the `transferUSDEUR(_, _)`
//  method asks for a destination account in EUR

accountUSD1.transferEURUSD(100, to: accountEUR1)
// ^- This line won't compile since the `transferEURUSD(_, _)`
//  method is only available for account in EUR
```

# Few references

- https://www.swiftbysundell.com/articles/phantom-types-in-swift/
- https://swiftwithmajid.com/2021/02/18/phantom-types-in-swift/
- https://www.hackingwithswift.com/plus/advanced-swift/how-to-use-phantom-types-in-swift
- https://flaviocopes.com/finite-state-machines
