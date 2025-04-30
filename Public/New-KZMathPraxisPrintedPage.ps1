Function New-KZMathPraxisPrintedPage {
    <#
    .SYNOPSIS
        Function to generate and print a math praxis page with random numbers and operators.
    .DESCRIPTION
        Function generates a math praxis page with random numbers and operators, formatted for printing.
        The function takes parameters for the range of numbers, the number of operations, and the operators to be used.
        After generating the math problems, it formats them into a string and sends it to a printer.
        The function also allows for customization of the delimiter size and the maximum result of the operations.
    .EXAMPLE
        New-KZMathPraxisPrintedPage -Operator + -FirstMin 3 -FirstMax 12 -SecondMin 3 -SecondMax 12 -MaxSum 25 
        Printing a math praxis page with addition operations, where the first operand is between 3 and 12, the second operand is between 3 and 12, and the maximum sum of the result is 25.
        Approximately for 5-6 year old.
    .EXAMPLE
        New-KZMathPraxisPrintedPage -Operator * -FirstMin 3 -FirstMax 12 -SecondMin 3 -SecondMax 12
        Printing a math praxis page with multiplication operations, where the first operand is between 3 and 12, the second operand is between 3 and 12.
        Approximately for any kid practicing tables.
    #>
    [CmdletBinding()]
    Param (
        # Operators to be used in praxis
        [Parameter(Mandatory)]
        [ValidateSet(
            '+',
            '-',
            '*',
            '/'
        )]
        [string[]]$Operator,

        # Minimum number for the first operand
        [Parameter(Mandatory)]
        [int]$FirstMin,

        # Maximum number for the first operand
        [Parameter(Mandatory)]
        [int]$FirstMax,

        # Minimum number for the second operand
        [Parameter(Mandatory)]
        [int]$SecondMin,

        # Maximum number for the second operand
        [Parameter(Mandatory)]
        [int]$SecondMax,

        # Number of praxis to generate
        [Parameter()]
        [int]$PraxisCount = 180,

        # Maximum result
        [Parameter()]
        [int]$MaxResult,

        # Number of spaces in the delimiter
        [Parameter()]
        $DelimiterSize = 4
    )
    $delimiter = ' ' * $DelimiterSize

    $praxis = [System.Collections.ArrayList]::new()

    $firstMaxLength = [math]::max($FirstMax.ToString().Length, $FirstMin.ToString().Length)
    $secondMaxLength = [math]::max($SecondMax.ToString().Length, $SecondMin.ToString().Length)

    while ($praxis.Count -lt $PraxisCount) {
        $first = Get-Random -Minimum $FirstMin -Maximum $FirstMax
        $second = Get-Random -Minimum $SecondMin -Maximum $SecondMax
        $selectedOperator = Get-Random -InputObject $Operator

        $normalizedFirst = $first.ToString().PadLeft($firstMaxLength, ' ')
        $normalizedSecond = $second.ToString().PadLeft($secondMaxLength, ' ')
        $praxisText = "$normalizedFirst $selectedOperator $normalizedSecond"
        $testScriptBlock = [scriptblock]::Create($praxisText)
        if (
            $PSBoundParameters.ContainsKey('MaxResult') -and    
            $testScriptBlock.Invoke() -gt $MaxResult
        ) {
            continue
        }
        $praxisTextFormatted = $praxisText -replace '\*', 'X'  -replace '/', ':'
        $null = $praxis.Add("$praxisTextFormatted =       ")
    }

    $stringBuilder = [System.Text.StringBuilder]::new()

    for ($i = 0; $i -lt $praxis.Count; $i = $i + 4) {
        if ($i % 5  -eq 0) {
            $stringBuilder.AppendLine([System.Environment]::NewLine) | Out-Null        
        }
        $singleLine = "{1}{0}{2}{0}{3}{0}{4}{0}" -f $delimiter, $praxis[$i], $praxis[$i + 1], $praxis[$i + 2], $praxis[$i + 3]
        $stringBuilder.AppendLine($singleLine) | Out-Null
    }

    $stringBuilder.ToString() | Out-KZPrinter -FontSize 10 -PaperSize 'A4'
}