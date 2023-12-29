

using Plots
using Printf

"""
computes the amount of taxes due, given gross income x

For a person living in Milano.

brackets = [15000, 28000, 55000]
national_tax_rates = [0.23, 0.25, 0.30, 0.43]
lombardy_tax_rates = [0.0123, 0.0158, 0.0172, 0.0173]

tested against https://www.irpef.info/calcola-irpef-online

"""
function tax_function(x)
    national_tax_rates = [0.23, 0.25, 0.30, 0.43]
    lombardy_tax_rates = [0.0123, 0.0158, 0.0172, 0.0173]
    communale_milano = 0.008
    rates = national_tax_rates + lombardy_tax_rates .+ communale_milano
    z = if x < 15001
        rates[1] * x 
    elseif x < 28001
        rates[1] * 15000 + rates[2] * (x - 15000)
    elseif x < 50001
        rates[1] * 15000 + rates[2] * (28000 - 15000) + rates[3] * (x - 28000)
    else
        rates[1] * 15000 + rates[2] * (28000 - 15000) + rates[3] * (50000 - 28000) + rates[4] * (x - 50000)
    end

    # 
    z
end

sconto_fiscale(x,γ) = x * γ

function net_wage_month(Gross,γ)
    # 1. protect income from taxation
    net_protected = sconto_fiscale(Gross,γ)

    # 2. apply tax rate to taxable income
    taxed = Gross - net_protected

    # 3. net pay out of `taxed`
    net_taxed = taxed - tax_function(taxed)

    (net_protected + net_taxed) / 13
end    

function plot_sconto(Y)
    plot(0:0.01:1, x -> net_wage_month(Y,x), title = "Retribuzione Annua Lorda: $Y", xlabel = "sconto fiscale", ylab = "Netto Mensile", leg = false, lw = 3,xformatter = x -> string(Integer(100x),"%"),
    xticks = [0,0.25,0.5,0.75,0.9,1],
    yticks = [floor(Int,net_wage_month(Y,0.0)),
              floor(Int,net_wage_month(Y,0.25)),
              floor(Int,net_wage_month(Y,0.5)),
              floor(Int,net_wage_month(Y,0.9))])
    vline!([0.9], color = :black)
    hline!([net_wage_month(Y,0.9)], color = :black)
    # vline!([0.5], color = :black, linestyle = :dash)
    # hline!([net_wage_month(Y,0.5)], color = :black, linestyle = :dash)
    savefig("sconto_fiscale.pdf")

end

function print_sconto(Y)
    println()
    
    println("Retribuzione complessiva annua lorda: $Y")
    println("----------------------------------------------")
    println()
    println("Prof Associato residente a Milano.")
    println()
    @printf("Sconto fiscale = %2d%% -> Netto mensile = %d Euro\n", 0, net_wage_month(Y,0.0))
    @printf("Sconto fiscale = %2d%% -> Netto mensile = %d Euro\n", 50, net_wage_month(Y,0.5))
    @printf("Sconto fiscale = %2d%% -> Netto mensile = %d Euro\n", 90, net_wage_month(Y,0.9))

end










