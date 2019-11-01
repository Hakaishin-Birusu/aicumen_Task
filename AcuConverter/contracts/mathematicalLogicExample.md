# explaination of logic used for conversion via mathematical example

# example 1 : Converting from usd to inr
```
let user send 100 cents (i.e, 1 USD)
And as OraclizeResult we get "70.42189" INR for 1USD

logic is ,

1) converting orcalize result to integer and paise 

uint uintPrice = parseInt("70.42189",2) // it will result in 7042 paise 

2) now finding actual price 

uint amount = (100 * 7042)/100 // which will result in 7042 paise 

hence , 
we are sending 7042 Paise or 70.42 INR token for 1 USD or 100 cents
```

# example 2 Converting from usd to inr

```
let user send 150 cents (i.e, 1.5 USD)
And as OraclizeResult we get "70.42189" INR for 1USD

logic is ,

1) converting orcalize result to integer and paise 

uint uintPrice = parseInt("70.42189",2) // it will result in 7042 paise 

2) now finding actual price 

uint amount = (150 * 7042)/100 // which will result in 10563 paise 

hence , 
we are sending 10563 Paise or 105.63 INR token for 1.5 USD or 150 cents
```

# example 3 Converting from inr to usd

```
let user send 100 paise (i.e, 1 INR)
And as OraclizeResult we get "0.01" USD for 1 INR

logic is ,

1) converting orcalize result to integer and cent 

uint uintPrice = parseInt("0.01",2) // it will result in 1 cents

2) now finding actual price 

uint amount = (100 * 1)/100 // which will result in 1 cents 

hence , 
we are sending 1 cents or 0.01 USD token for 1 INR or 100 paise
```