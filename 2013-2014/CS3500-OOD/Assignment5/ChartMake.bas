Attribute VB_Name = "ChartMake"
Sub makeWordCharts()
    For i = 11 To 0 Step -1
        Set mySheet = Sheets("Words")
        Dim Title As String
        Title = mySheet.Range("A" & 7 * i + 2).text & ", " & mySheet.Range("B" & 7 * i + 2).text
        
        Charts.Add
        
        With ActiveChart
            .SetSourceData Source:=mySheet.Range(mySheet.Cells(7 * i + 2, 5), mySheet.Cells(7 * i + 7, 7))
            .ChartType = xl3DColumn
            .HasTitle = True
            .ChartTitle.Characters.text = Title
            .Name = "words" & i
            .BarShape = xlCylinder
            .ChartColor = 10
            .ApplyDataLabels
            Set valAx = .Axes(xlValue, xlPrimary)
            Set catAx = .Axes(xlCategory, xlPrimary)
            Set serAx = .Axes(xlSeriesAxis, xlPrimary)
            valAx.HasTitle = True
            valAx.AxisTitle.Characters.text = "Time in ms"
            ' valAx.LogBase = 10
            catAx.HasTitle = True
            catAx.AxisTitle.Characters.text = "Number of Words Added From File"
            catAx.CategoryNames = Array(2000, 4000, 8000, 16000, 20000, 24000)
            serAx.HasTitle = True
            serAx.AxisTitle.Characters.text = "Operation"
            .SeriesCollection(1).PlotOrder = 3
            .SeriesCollection(3).Name = "Build"
            .SeriesCollection(1).Name = "Iterate"
            .SeriesCollection(2).Name = "Contains"
        End With
    Next
End Sub

Sub makeLitCharts()
    For i = 1 To 0 Step -1
        Set mySheet = Sheets("Literature")
        Dim Title As String
        Title = mySheet.Range("B" & 4 * i + 2).text
        
        Charts.Add
        
        With ActiveChart
            .SetSourceData Source:=mySheet.Range(mySheet.Cells(4 * i + 2, 4), mySheet.Cells(4 * i + 4, 6))
            .PlotBy = xlColumns
            .ChartType = xl3DColumn
            .HasTitle = True
            .ChartTitle.Characters.text = Title
            .Name = "lit" & i
            .BarShape = xlCylinder
            .ChartColor = 10
            .ApplyDataLabels
            Set valAx = .Axes(xlValue, xlPrimary)
            Set catAx = .Axes(xlCategory, xlPrimary)
            Set serAx = .Axes(xlSeriesAxis, xlPrimary)
            valAx.HasTitle = True
            valAx.AxisTitle.Characters.text = "Time in ms"
            ' valAx.LogBase = 10
            catAx.HasTitle = True
            catAx.AxisTitle.Characters.text = "Comparator Used"
            catAx.CategoryNames = mySheet.Range("A" & (4 * i + 2) & ":A" & (4 * i + 4))
            serAx.HasTitle = True
            serAx.AxisTitle.Characters.text = "Operation"
            .SeriesCollection(1).PlotOrder = 3
            .SeriesCollection(3).Name = "Build"
            .SeriesCollection(1).Name = "Iterate"
            .SeriesCollection(2).Name = "Contains"
        End With
    Next
End Sub

Function cleanCharts()
    For Each Chart In Charts
        Chart.Delete
    Next Chart
End Function
