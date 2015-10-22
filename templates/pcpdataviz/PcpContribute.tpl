<h1><span id="nbcontrib"></span> Contributions for a total of <span id="amount"></span></h1>
<div id="type" style="width:1000px;">
    <strong>Campaigns</strong>
    <a class="reset" href="javascript:pietype.filterAll();dc.redrawAll();" style="display: none;">reset</a>
    <div class="clearfix"></div>
</div>

<div id="instrument" style="width:250px;">
    <strong>Top Personal Campaign Pages</strong>
    <a class="reset" href="javascript:pieinstrument.filterAll();dc.redrawAll();" style="display: none;">reset</a>
    <div class="clearfix"></div>
</div>

<div id="day-of-week-chart">
    <strong>Top Donors</strong>
    <a class="reset" href="javascript:dayOfWeekChart.filterAll();dc.redrawAll();" style="display: none;">reset</a>
    <div class="clearfix"></div>
</div>

<div class="row clear">
    <div id="monthly-move-chart">
        <strong>Amount by month</strong>
        <span class="reset" style="display: none;">range: <span class="filter"></span></span>
        <a class="reset" href="javascript:moveChart.filterAll();volumeChart.filterAll();dc.redrawAll();"
style="display: none;">reset</a>
        <div class="clearfix"></div>
    </div>
</div>

<div id="monthly-volume-chart"></div>

<div class="clear"></div>

<script>
    'use strict';

    var data = {crmSQL file="pcp_details"};
    var i = {crmAPI entity="OptionValue" option_group_id="10"}; {*todo on 4.4, use the payment_instrument as id *}

    {literal}
          if(!data.is_error){
            var instrumentLabel = {};
            i.values.forEach (function(d) {
                instrumentLabel[d.value] = d.label;
            });

            var numberFormat = d3.format(".2f");
            var volumeChart=null,dayOfWeekChart=null,moveChart=null,pieinstrument,pietype;  

            cj(function($) {
                // create a pie chart under #chart-container1 element using the default global chart group
                pietype = dc.rowChart("#type");
                pieinstrument = dc.rowChart("#instrument");
                volumeChart = dc.barChart("#monthly-volume-chart");
                dayOfWeekChart = dc.rowChart("#day-of-week-chart");
                //var moveChart = dc.seriesChart("#monthly-move-chart");
                moveChart = dc.lineChart("#monthly-move-chart");
                var dateFormat = d3.time.format("%Y-%m-%d");
                //data.values.forEach(function(d){data.values[i].dd = new Date(d.receive_date)});
                var pcpNames = getPCPName(data.values);
                var donorNames = getDonorName(data.values);
                
                data.values.forEach(function(d){d.dd = dateFormat.parse(d.receive_date); d.name = d.page_type;});
                var min = d3.min(data.values, function(d) { return d.dd;} );
                var max = d3.max(data.values, function(d) { return d.dd;} );
                var ndx                 = crossfilter(data.values),
                all = ndx.groupAll();

                var type        = ndx.dimension(function(d) {return d.page_type;});
                var typeGroup   = type.group().reduceSum(function(d) { return d.count; });
                
                var donor        = ndx.dimension(function(d) {return d.donor_id;});
                var donorGroup   = donor.group().reduceSum(function(d) { return d.amount; });

                var instrument        = ndx.dimension(function(d) {return d.pcp_id;});
                var instrumentGroup   = instrument.group().reduceSum(function(d) { return d.count; });

                var byMonth     = ndx.dimension(function(d) { return d3.time.month(d.dd); });
                var byDay       = ndx.dimension(function(d) { return d.dd; });
                var volumeByMonthGroup  = byMonth.group().reduceSum(function(d) { return d.count; });
                var totalByDayGroup     = byDay.group().reduceSum(function(d) { return d.total; });

                var dayOfWeek = ndx.dimension(function (d) { 
                    var day = d.dd.getDay(); 
                    var name=["Sun","Mon","Tue","Wed","Thu","Fri","Sat"];
                    return day+"."+name[day]; 
                }); 
    
    


                var group=ndx.groupAll().reduce(
                    function(a, d) { 
                        a.total += d.total; 
                        a.count += d.count; 
                        return a;
                    },
                    function(a, d) { 
                        a.total -= d.total; 
                        a.count -= d.count; 
                        return a; 
                    },
                    function() { 
                        return {total:0, count:0};
                    }
                );

                var contribND   = dc.numberDisplay("#nbcontrib")
                    .group(group)
                    .valueAccessor(function (d) {
                    return d.count;})
                    .formatNumber(d3.format("3.3s"));

                var amountND    = dc.numberDisplay("#amount")
                    .group(group)
                    .valueAccessor(function(d) {return d.total});



                var dayOfWeekGroup = dayOfWeek.group(); 
                
                dayOfWeekChart.width(300)
                    .height(420)
                    .margins({top: 20, left: 10, right: 10, bottom: 20})
                    .group(donorGroup)
                    .dimension(donor)
		    .gap(1)
                    .colors(d3.scale.category10())
                    .label(function (d) {
                        return donorNames[d.key];
                    })
                    .title(function (d) {
                        return d.value;
                    })
                    .data(function (group) {
                        return group.top(20);
                    })
                    .elasticX(true)
                    .xAxis().ticks(4);

                pieinstrument
                    .width(200)
                    .height(420)
	    .margins({top: 20, left: 10, right: 10, bottom: 20})
                    .dimension(instrument)
                    .group(instrumentGroup)
                    .title(function(d) {
                        return d.value;
                    })
		     .gap(1)
		     .colors(d3.scale.category10())
                    .label(function(d) {
                        return pcpNames[d.key];
                    })
                    .data(function (group) {
                        return group.top(20);
                    })
		    .elasticX(true)
		    .xAxis().ticks(4);
                   

                pietype
                    .width(850)
                    .height(420)
        .margins({top: 20, left: 10, right: 10, bottom: 20})
                    .dimension(type)
                    .colors(d3.scale.category10())
                    .group(typeGroup)
           .gap(0)
                    .label(function (d) {
                        return d.key;
                    })
                    .title(function (d) {
                        return d.value;
                    }) 
        .elasticX(true)
                    .xAxis().ticks(4);

                //.round(d3.time.month.round)
                //.interpolate('monotone')
                moveChart.width(850)
                    .height(200)
                    .transitionDuration(1000)
                    .margins({top: 30, right: 50, bottom: 25, left: 40})
                    .dimension(byDay)
                    .mouseZoomable(true)
                    .x(d3.time.scale().domain([min,max]))
                    .xUnits(d3.time.months)
                    .elasticY(true)
                    .renderHorizontalGridLines(true)
                    .legend(dc.legend().x(800).y(10).itemHeight(13).gap(5))
                    .brushOn(false)
                    .rangeChart(volumeChart)
                    .group(totalByDayGroup)
                    .valueAccessor(function (d) { 
                        return d.value;
                    })
                    .title(function (d) {
                        var value = d.value;
                        if (isNaN(value)) value = 0;
                        return dateFormat(d.key) + "\n" + numberFormat(value);
                    });

                volumeChart.width(850)
                    .height(200)
                    .margins({top: 0, right: 50, bottom: 20, left:40})
                    .dimension(byMonth)
                    .group(volumeByMonthGroup)
                    .centerBar(true)
                    .gap(1)
                    .x(d3.time.scale().domain([min, max]))
                    .round(d3.time.month.round)
                    .xUnits(d3.time.months);

                dc.renderAll();
                //  pietype.render();
            });//end cj
        }
        else{
            cj('.eventsoverview').html('<div style="color:red; font-size:18px;">Civisualize Error. Please contact Admin.'+data.error+'</div>');
        }
        
    function getPCPName(data){
      var pcpnames = [];
      for(var i=0; i<data.length; i++ ){
        pcpnames[data[i]['pcp_id']] = data[i]['instrument'];
      }
      return pcpnames;
    }
    
    function getDonorName(data){
      var donornames = [];
      for(var i=0; i<data.length; i++ ){
        donornames[data[i]['donor_id']] = data[i]['donor_name'];
      }
      return donornames;
    }
    
    
    {/literal}
</script>
<div class="clear"></div>
