
attachSmartCalendar = function(t, type, max_date, min_date, max_offset, min_offset,callback,input){
    id = t.id
    DatePicker = new smartCalendar('DatePicker', t, max_date, min_date, max_offset, min_offset)
    if (typeof type == "string") {
        type = type.toLowerCase();
        switch (type) {
            case "arrows":
                DatePicker.useArrows()
                break;
            case "dropdown":
                DatePicker.useDropDowns()
                break;
            default:
                DatePicker.useArrows()
                break;
        }
    }
    
   DatePicker.ds_draw_calendar()
   if(input!=undefined){
     DatePicker.ds_element = input
   }
   DatePicker.callBackFunction = callback;
    
}


/*   Smart Calendar
 *   This calendar object allows users to pick dates for input boxes. It allows
 *   for the specification of valid date ranges and prevents users from choosing dates
 *   outside of the ranges. In addition, it has two naviagtion options. You can choose
 *   an arrow driven control type or a drop down control type.
 *   @params:
 *   - obj_name: the name of the calendar object that you create. for
 *     example, if you want your object to be called myCalObj you would pass 'myCalObj'
 *     to the smartDatePicker constructor
 *
 *   - input_field: the id of the form input year that the calendar object is attached to
 *
 *   - max_date: this is the top date limit for the smart calendar object. this value can be either
 *     a string e.g. '11/20/2008' or an actual date object
 *
 *   - min_date: this is the bottom date limit for the smart calendar object. this value can be either
 *     a string e.g. '11/20/2008' or an actual date object
 *
 *   - max_offset: this is the offset either positive or negative to apply to the max_date.
 *     e.g. if you wanted to add 7 days to the max_date you would pass in +7
 *
 *   - min_offset: this is the offset either positive or negative to apply to the min_date.
 *     e.g. if you wanted to subtract 7 days from the min_date you would pass in -7
 *
 */
function smartCalendar(obj_name, input_field, max_date, min_date, max_offset, min_offset){
    this.object_name = obj_name;
    this.ds_i_date = new Date();
    this.ds_c_month = this.ds_i_date.getMonth() + 1;
    this.ds_c_year = this.ds_i_date.getFullYear();
    this.$_date_range_obj = new dateConstraintObject(max_date, min_date, max_offset, min_offset)
    this.input_field = input_field;
    this.showTopControls = true;
    
    this.setControlType = function(showDropDowns){
        this.showTopControls = !showDropDowns
    }
    
    this.useArrows = function(){
        this.showTopControls = true;
    }
    
    this.useDropDowns = function(){
        this.showTopControls = false;
    }
    
    this.ds_element = input_field
    // Get Element By Id
    
    this.ds_getel = function(id){
        var cal = document.getElementById(id);
        return cal;
    }
    
    // Get the left and the top of the element.
    this.ds_getleft = function(el){
        var tmp = el.offsetLeft;
        el = el.offsetParent
        while (el) {
            tmp += el.offsetLeft;
            el = el.offsetParent;
        }
        
        return tmp;
    }
    
    this.ds_gettop = function(el){
        var tmp = el.offsetTop;
        el = el.offsetParent
        while (el) {
            tmp += el.offsetTop;
            el = el.offsetParent;
        }
        return tmp;
    }
    
    // Output Element
    this.ds_oe = this.ds_getel('ds_calclass');
    // Container
    this.ds_ce = this.ds_getel('ds_conclass');
    
    // Output Buffering
    this.ds_ob = '';
    this.ds_ob_clean = function(){
        this.ds_ob = '';
    }
    
    this.ds_ob_flush = function(){
        this.ds_oe.innerHTML = this.ds_ob;
        this.ds_ob_clean();
        
    }
    
    this.ds_echo = function(t){
        this.ds_ob += t;
    }
    
    // Text Element...
    this.ds_monthnames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']; // You can translate it for your language.
    this.ds_daynames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']; // You can translate it for your language.
    // Calendar template
    
    this.ds_template_main_above = function(t, max_month, max_year){
    
        html_str = '<table class="ds_tbl" cellpadding="3" cellspacing="0" >'
        html_str = html_str + '<tr>'
        if (this.showTopControls) {
            var allow_forward_month = true
            var allow_forward_year = true
            var allow_backward_month = true
            var allow_backward_year = true
            
            if (this.$_date_range_obj) {
                allow_forward_month = this.$_date_range_obj.validateDateChange(this.ds_c_year, (this.ds_c_month + 1))
                allow_forward_year = this.$_date_range_obj.validateDateChange((this.ds_c_year + 1), this.ds_c_month)
                allow_backward_month = this.$_date_range_obj.validateDateChange(this.ds_c_year, (this.ds_c_month - 1))
                allow_backward_year = this.$_date_range_obj.validateDateChange((this.ds_c_year - 1), this.ds_c_month)
            }
            
            if (allow_backward_year) {
                html_str += '<td class="ds_head" border=0 style="cursor: pointer" onclick="' + this.object_name + '.ds_py();">&lt;&lt;</td>'
            }
            else {
                // html_str += '<td class="ds_head"  border=0 style="cursor: pointer">&nbsp;&nbsp;</td>'
            }
            
            if (allow_backward_month) {
                html_str += '<td class="ds_head" style="cursor: pointer" onclick="' + this.object_name + '.ds_pm();">&lt;</td>'
            }
            else {
                //html_str += '<td class="ds_head">&nbsp; </td>'
            }
            
            colspan = 3
            colspan = allow_backward_year ? colspan : colspan + 1
            colspan = allow_backward_month ? colspan : colspan + 1
            colspan = allow_forward_month ? colspan : colspan + 1
            colspan = allow_forward_year ? colspan : colspan + 1
            
            html_str += '<td class="ds_head" style="cursor: pointer"  colspan="' + colspan + '"><a href="javascript:void(0);" onclick="' + this.object_name + '.ds_hi();">[Close]'
            html_str += '</a><a href="javascript:void(0);" style="cursor: pointer" onclick="' + this.object_name + '.clear();" >[Clear]</td>'
            
            if (allow_forward_month) {
                html_str += '<td class="ds_head" style="cursor: pointer" onclick="' + this.object_name + '.ds_nm();">&gt;</td>'
            }
            else {
                //html_str += '<td class="ds_head"  >&nbsp; </td>'
            }
            
            if (allow_forward_year) {
                html_str += '<td class="ds_head" style="cursor: pointer" onclick="DatePicker.ds_ny();">&gt;&gt;</td>'
            }
            else {
                //html_str += '<td class="ds_head">&nbsp;&nbsp; </td>'
            }
            html_str += '</tr>'
            html_str += '<tr><td colspan="7" class="ds_head">' + t + '</td></tr>'
        }
        else {
            html_str += '<td class="ds_head" colspan="7" style="cursor: pointer" onclick="' + this.object_name + '.ds_hi();' + this.object_name + '=null" colspan="3">[Close]</td></tr><tr>'
            html_str += '<td colspan="7" class="ds_head"><span id = "mo_sel_box">' + this.getMonthSelectBox() + "</span>&nbsp;&nbsp;"
            html_str += '<span id = "yr_sel_box" >' + this.getYearSelectBox() + '</span></td>'
            html_str += '</tr>'
            html_str += '<tr><td colspan="7" class="ds_head">' + t + '</td></tr>'
            html_str += '</tr>'
        }
        return html_str
        
    }
    
    this.ds_template_day_row = function(t){
        return '<td class="ds_subhead">' + t + '</td>';
        // Define width in CSS, XHTML 1.0 Strict doesn't have width property for it.
    }
    
    this.ds_template_new_week = function(){
        return '</tr><tr>';
    }
    
    this.ds_template_blank_cell = function(colspan){
        return '<td class="ds_blank_cell"  colspan="' + colspan + '">1</td>'
    }
    
    this.ds_template_day = function(d, m, y){
        return '<td class="ds_cell"  onclick="' + this.object_name + '.ds_onclick(' + d + ',' + m + ',' + y + ')"><a href="javascript:void()">' + d + '</a></td>';
        
        // Define width the day row.
    }
    
    this.ds_template_main_below = function(){
        return '</tr>' +
        '</table>';
    }
    
    // This one draws calendar...
    this.ds_draw_calendar = function(m, y){
        // First clean the output buffer.
        
        
        m = m || this.ds_c_month
        y = y || this.ds_c_year
        
        
        this.ds_ob_clean();
        // Here we go, do the header
        mon_str = this.ds_monthnames[m - 1] + ' ' + y
        
        this.ds_echo(this.ds_template_main_above(mon_str));
        
        //draw day names
        for (i = 0; i < 7; i++) {
            this.ds_echo(this.ds_template_day_row(this.ds_daynames[i]));
        }
        // Make a date object.
        var ds_dc_date = new Date(y, m - 1, 1);
        if (m == 1 || m == 3 || m == 5 || m == 7 || m == 8 || m == 10 || m == 12) {
            days = 31;
        }
        else 
            if (m == 4 || m == 6 || m == 9 || m == 11) {
                days = 30;
            }
            else {
                days = (y % 4 == 0) ? 29 : 28;
            }
        var first_day = ds_dc_date.getDay();
        var first_loop = 1;
        // Start the first week
        this.ds_echo(this.ds_template_new_week());
        
        if (first_day != 0) {
            // If sunday is not the first day of the month, make a blank cell...
            i = 0
            while (i < first_day) {
                i++;
                this.ds_echo(this.ds_template_blank_cell(1));
            }
        }
        
        var j = first_day;
        
        /**Have to do this b/c of first day of month bug. Ugly, hacky, but hey
         * it works for now
         */
        for (i = 0; i < 5000; i++) {
            s = "zzzzz"
        }
        for (i = 0; i < days; i++) {
            // Today is sunday, make a new week.
            // If this sunday is the first day of the month,
            // we've made a new row for you already.
            if (j == 0 && !first_loop) {
                // New week!!
                this.ds_echo(this.ds_template_new_week());
            }
            // Make a row of that day!
            if (this.$_date_range_obj == null || this.$_date_range_obj.showIndividualDay(i, y, m)) {
                this.ds_echo(this.ds_template_day(i + 1, m, y));
            }
            else {
                this.ds_echo(this.ds_template_blank_cell(1))
            }
            
            first_loop = 0;
            // What is the next day?
            j++;
            j %= 7;
        }
        // Do the footer
        this.ds_echo(this.ds_template_main_below());
        // And let's display..
        this.ds_ob_flush();
		this.ds_ce.style.position = 'absolute'
        this.ds_ce.style.top = (this.ds_gettop(this.input_field) + 30) + 'px'
        this.ds_ce.style.left = this.ds_getleft(this.input_field) + 'px'
        this.ds_ce.style.display = ''
        this.hideElements();
    }
    
    
    this.$_date_range_obj;
    // A function to show the calendar.
    // When user click on the date, it will set the content of t.
    
    // Hide the calendar.
    this.ds_hi = function(){
        this.ds_ce.style.display = 'none';
        this.showElements();
        
    }
    
    this.clear = function(){
        this.ds_ce.style.display = 'none';
        this.ds_element.value = ""
        this.showElements();
    }
    
    // Moves to the next month...
    this.ds_nm = function(){
        // Increase the current month.
        this.ds_c_month++;
        // We have passed December, let's go to the next year.
        // Increase the current year, and set the current month to January.
        if (this.ds_c_month > 12) {
            this.ds_c_month = 1;
            this.ds_c_year = this.ds_c_year + 1;
        }
        
        // Redraw the calendar.
        this.ds_draw_calendar(this.ds_c_month, this.ds_c_year);
    }
    
    // Moves to the previous month...
    this.ds_pm = function(){
        this.ds_c_month = this.ds_c_month - 1; // Can't use dash-dash here, it will make the page invalid.
        // We have passed January, let's go back to the previous year.
        // Decrease the current year, and set the current month to December.
        if (this.ds_c_month < 1) {
            this.ds_c_month = 12;
            this.ds_c_year = this.ds_c_year - 1; // Can't use dash-dash here, it will make the page invalid.
        }
        
        // Redraw the calendar.
        this.ds_draw_calendar(this.ds_c_month, this.ds_c_year);
    }
    
    // Moves to the next year...
    this.ds_ny = function(){
        // Increase the current year.
        this.ds_c_year++;
        this.ds_draw_calendar(this.ds_c_month, this.ds_c_year);
        
    }
    
    // Moves to the previous year...
    this.ds_py = function(){
        this.ds_c_year = this.ds_c_year - 1;
        // Redraw the calendar.
        this.ds_draw_calendar(this.ds_c_month, this.ds_c_year);
    }
    
    // Format the date to output.
    this.ds_format_date = function(d, m, y){
        // 2 digits month.
        m2 = '00' + m;
        m2 = m2.substr(m2.length - 2);
        // 2 digits day.
        d2 = '00' + d;
        d2 = d2.substr(d2.length - 2);
        // MM/DD/YYYY
        return m2 + '/' + d2 + '/' + y;
    }
    
    
    this.callBackFunction;
    
    // When the user clicks the day.
    this.ds_onclick = function(d, m, y){
        // Hide the calendar.
        this.ds_hi();
        // Set the value of it, if we can.
        if (typeof(this.ds_element.value) != 'undefined') {
            this.ds_element.value = this.ds_format_date(d, m, y);
        }
        else 
            if (typeof(this.ds_element.innerHTML) != 'undefined') {
                this.ds_element.innerHTML = this.ds_format_date(d, m, y);
            //validators[ds_element.id].check();
            // I don't know how should we display it, just alert it to user.
            }
            else {
                alert(this.ds_format_date(d, m, y));
            }
        
        
        if (this.callBackFunction != 'undefined') {
            this.callBackFunction();
            
            //setTimeout(this.object_name+'.callBackFunction()',100);
        }
        
        this.$_date_range_obj.max_date = null;
        this.$_date_range_obj.min_date = null;
        setTimeout(this.object_name + '= null', 100);
        
    }
    
    
    this.changeMandY = function(yr, m){
        yr = yr == null ? this.ds_c_year : document.getElementById('smart_cal_yr_box').options[yr].value;
        m = m == null ? m : document.getElementById('smart_cal_mon_box').options[m].value
        
        isValid = this.$_date_range_obj.validateDateChange(yr, m)
        if (isValid) {
            this.ds_c_month = m || this.ds_c_month
            this.ds_c_year = yr || this.ds_c_year
            this.ds_draw_calendar(this.ds_c_month, this.ds_c_year);
        }
        else 
            if (m != null) {
            
                span = document.getElementById('yr_sel_box')
                this.ds_c_month = m
                span.innerHTML = this.getYearSelectBox(m)
                
            }
    }
    
    
    this.getYearSelectBox = function(drop_down_month){
        curr_month = drop_down_month || this.ds_c_month
        str = ""
        str += '<select size="1" name="smart_cal_yr_box" id="smart_cal_yr_box" onchange= "' + this.object_name + '.changeMandY(this.selectedIndex)">'
        yr = new Date().getFullYear();
        y = yr - 10;
        str += '<option value="" >Choose Year </option>';
        for (y = yr - 9; y < yr + 10; y++) {
            valid = this.$_date_range_obj.validateDateChange(y, curr_month)
            if (y == this.ds_c_year && valid) {
                str += "<option value=\"" + y + "\" selected>" + y + "</option>";
            }
            else 
                if (valid) {
                    str += "<option value=\"" + y + "\">" + y + "</option>";
                }
        }
        
        str += "</select>";
        
        return str;
    }
    
    this.getMonthSelectBox = function(){
        str = ""
        str += '<select size="1" name="smart_cal_mon_box" id="smart_cal_mon_box" onchange= "' + this.object_name + '.changeMandY(null,this.selectedIndex)">'
        for (m = 1; m <= this.ds_monthnames.length; m++) {
        
            if (m == this.ds_c_month) {
                str += "<option value=\"" + (m) + "\" selected>" + this.ds_monthnames[m - 1] + "</option>";
            }
            else 
                if (true || this.$_date_range_obj.validateDateChange(this.ds_c_year, m)) {
                    str += '<option value="' + (m) + '">' + this.ds_monthnames[m - 1] + '</option>';
                }
            
        }
        str += "</select>";
        return str;
    }
    
    
    
    this.hiddenElements = new Array()
    
    this.setPosRange = function(){
        width = this.ds_ce.offsetWidth
        height = this.ds_ce.offsetHeight
        offsetLeft = this.ds_ce.offsetLeft
        offsetTop = this.ds_ce.offsetTop
        this.start_x = offsetLeft;
        this.end_x = width + offsetLeft;
        this.start_y = offsetTop;
        this.end_y = height + offsetTop;
        
    }
    
    
    
    this.inRange = function(el){
        this.setPosRange()
        x = this.ds_getleft(el)
        y = this.ds_gettop(el)
        overlaps_x = ((this.start_x - 50) < x) && this.end_x > x
        overlaps_y = ((this.start_y - 20) < y) && ((this.end_y + 20) > y)
        
        return overlaps_x && overlaps_y;
    }
    
    this.hideElements = function(){
        ieVer = this.ieVersion();
        if (ieVer == -1 || ieVer > 6) {
        
            return false;
        }
        selects = document.getElementsByTagName('select')
        left = ""
        left += this.ds_ce.offsetTop + ":" + this.ds_ce.offsetLeft + ":" + this.start_x + ":" + this.start_y + "\r\n"
        for (var i = 0; i < selects.length; i++) {
            el = selects[i]
            if (this.inRange(el) && el.id != 'smart_cal_yr_box' && el.id != 'smart_cal_mon_box') {
                el.style.display = "none"
                this.hiddenElements.push(el)
            }
        }
        
    }
    
    
    
    /*
     *  This solves the i.e. select box overlay problem
     *
     *
     */
    this.showElements = function(){
    
        while (this.hiddenElements.length > 0) {
            el = this.hiddenElements.pop()
            el.style.display = ""
        }
        
    }
    
    
    this.$ = function(){
        if (document.getElementById(id)) {
            return document.getElementById(id)
        }
        else 
            if (document.forms[0].elements[id]) {
                return document.forms[0].elements[id]
            }
    }
    
    
    this.ieVersion = function(){
        var rv = -1; // Return value assumes failure.
        if (navigator.appName == 'Microsoft Internet Explorer') {
            var ua = navigator.userAgent;
            var re = new RegExp("MSIE ([0-9]{1,}[\.0-9]{0,})");
            if (re.exec(ua) != null) 
                rv = parseFloat(RegExp.$1);
        }
        return rv;
    }
    
}


function dateConstraintObject(max_date, min_date, max_offset, min_offset){


    this.max_date = getDateObject(max_date, max_offset);
    this.min_date = getDateObject(min_date, min_offset);
    
    this.isMax = this.max_date != null && this.min_date == null;
    this.isMin = this.min_date != null && this.max_date == null;
    this.isRange = this.min_date != null && this.max_date != null;
    /*  
     if (max_offset && this.max_date) {
     this.max_date.setDate(this.max_date.getDate() + max_offset);
     }
     if (min_offset && this.min_date) {
     this.min_date.setDate(this.min_date.getDate() + min_offset);
     }
     */
    this.max_constraint_day = this.max_date ? this.max_date.getDate() : null
    this.max_constraint_month = this.max_date ? this.max_date.getMonth() + 1 : null
    this.max_constraint_year = this.max_date ? this.max_date.getFullYear() : null
    
    this.min_constraint_day = this.min_date ? this.min_date.getDate() : null
    this.min_constraint_month = this.min_date ? this.min_date.getMonth() + 1 : null
    this.min_constraint_year = this.min_date ? this.min_date.getFullYear() : null
    
    
    this.validateMax = function(year, month){
        m_valid = month == null ? true : month <= this.max_constraint_month
        y_valid = year <= this.max_constraint_year
        also_valid = month > this.max_constraint_month && year < this.max_constraint_year
        return (m_valid && y_valid) || also_valid
    }
    
    this.validateMin = function(year, month){
        m_valid = month == null ? true : month >= this.min_constraint_month
        y_valid = year >= this.min_constraint_year
        also_valid = month <= this.min_constraint_month && year > this.min_constraint_year
        return (m_valid && y_valid) || also_valid
    }
    
    this.validateDateChange = function(year, month){
        if (this.isMax) {
            return this.validateMax(year, month)
        }
        else 
            if (this.isMin) {
                return this.validateMin(year, month)
            }
            else 
                if (this.isRange) {
                    return this.validateMin(year, month) && this.validateMax(year, month)
                }
                else {
                    return true;
                }
    }
    
    this.showIndividualDay = function(i, year, month){
        test_date = new Date()
        test_date.setFullYear(year, month - 1, i + 1);
        
        if (this.isMax) {
            return this.max_date > test_date
        }
        else 
            if (this.isMin) {
                return this.min_date < test_date
            }
            else 
                if (this.isRange) {
                
                    return this.max_date > test_date && this.min_date < test_date
                }
                else {
                    return true;
                }
    }
    
}


function getDateObject(date, offset){
    if (typeof date == 'string') {
        if (date == "") {
            return null;
        }
        cMonth = date.substring(0, 2) - 1
        cDate = date.substring(3, 5)
        cYear = date.substring(6)
        
        dtObject = new Date(cYear, cMonth, cDate);
        
        if (offset) {
            dtObject.setDate(dtObject.getDate() + offset);
        }
        
        return dtObject;
    }
    else 
        if (date != null) {
            dtObject = new Date();
            dtObject.setDate(date.getDate());
            
            return dtObject;
        }
        else {
        
            return null;
        }
    
    
    
    
}



var tPicker
addTimePicker = function(e, input, obj_name, type){
    try {
       // cancelBubble(e);
        tPicker = new timePicker(input, 'tPicker');
        tPicker.isDobPicker = type != null && type == 'date'
        tPicker.addTimePicker();
    } 
    catch (e) {
        alert(e)
    }
}


function cancelBubble(e){
	 if (!e) 
            var e = window.event;
        e.cancelBubble = true;
        if (e.stopPropagation) 
            e.stopPropagation();	
}


function setValue(event){
    tPicker.setFieldValue(event);
}


timePicker = function(input_el, obj_name){
    this.input = input_el
    this.container_div = document.createElement('div')
    this.min_box;
    this.hour_box;
    this.am_box;
    this.year_box;
    this.objectName = obj_name;
    this.dont_hide = true;
    this.initial_hr;
    this.initial_min;
    this.initial_a_p;
    this.isDobPicker = true;
    this.initialized = false;
    this.addTimePicker = function(){
    
        this.container_div.classname = 'tp_box'
        this.container_div.id = "tpicker_box"
        
        try {
            this.setDefaults();
            this.container_div.style.position = 'absolute';
            span = this.addElement(this.container_div, 'span');
            box1 = span.appendChild(this.createBox1())
            span = this.addElement(this.container_div, 'span');
            box2 = span.appendChild(this.createBox2())
            span = this.addElement(this.container_div, 'span');     
			end_box = this.isDobPicker ? this.createYearBox() : this.createAPBox();
            box3 = span.appendChild(end_box)
            box1.style.height = "22px";
            box2.style.height = "22px";
            box3.style.height = "22px";
            this.settop();
            this.setleft();	
            sp = this.addElement(this.container_div, 'span');			
            sp.style.paddingLeft = "5px";
            cancel_link = this.addElement(sp, 'a');
            cancel_link.innerHTML = "<br\>Clear";
            cancel_link.style.textDecoration = "none";
            cancel_link.style.color = "#880011";
	
            cancel_link.onclick = function(e){
                cancelBubble(e);
                tPicker.input.value = "";
                tPicker.destroyTimePicker();
            };
			
            cancel_link.href = "javascript:void(0);";
            document.body.appendChild(this.container_div);
            try {
                document.body.addEventListener('click', function(event){
                    eval("tPicker.setFieldValue(event);")
                }, false)
                        } 
            catch(e){  
               document.body.attachEvent('onclick', setValue)              
            }                  
        } 
        catch (e) {	
            alert(e)
        }
	
    }
    
    this.handleBlur = function(){
        this.dont_hide = false;
    }
    
    
    this.setDefaults = function(){
    
        val = this.input.value || ""
        match_1 = this.isDobPicker ? /\d+\//i : /\d+:/i
        match_2 = this.isDobPicker ? /\/\d{2}/i : /:\d{2}/i
        match_3 = this.isDobPicker ? /\/\d{4}/i : /[A|P]M+/
        replace_char = this.isDobPicker ? "/" : ":"
        box_1 = val.match(match_1)
        box_2 = val.match(match_2)
        box_3 = val.match(match_3)
        a_p = val.match(/[A|P]M+/)
        
        if (box_1) {
            box_1 = box_1.toString()
            this.initial_box_1 = box_1.replace(replace_char, "")
        }
        
        if (box_2) {
            box_2 = box_2.toString()
            this.initial_box_2 = box_2.replace(replace_char, "")
        }
        
        if (box_3) {
            box_3 = box_3.toString()
            this.initial_3 = box_3.replace(replace_char, "")
        }
    }
    
    this.handleFocus = function(e){
        cancelBubble(e);
    }
    
    this.destroyTimePicker = function(e){
        if ($('tpicker_box')){
            $('tpicker_box').remove();
        }
        try {
            document.body.removeEventListener('click', function(event){
                eval("tPicker.setFieldValue(event);")
            }, false);
        } 
        catch (e) {
            document.body.detachEvent('onclick', setValue);         
        }       
    }
    
    
    this.addElement = function(el, tag){
        tag = document.createElement(tag);
        el.appendChild(tag);
        tag.style.margin = "0px";
        return tag;
    }
    
    this.setleft = function(){
        var tmp = this.input.offsetLeft;
        el = this.input.offsetParent
        while (el) {
            tmp += el.offsetLeft;
            el = el.offsetParent;
        }
        this.container_div.style.left = tmp + "px";
        return tmp;
    }
    
    this.settop = function(){
        var tmp = this.input.offsetTop;
        el = this.input.offsetParent
        while (el) {
            tmp += el.offsetTop;
            el = el.offsetParent;
        }
        this.container_div.style.top = tmp + "px";
        return tmp;
    }
    
    this.createBox1 = function(){
        var box = document.createElement('select')
        box.onchange = eval(this.objectName + ".handleFocus")
        box.onclick = eval(this.objectName + ".handleFocus")
        box.id = "hourBox"
        for (var i = 1; i < 13; i++) {
            y = document.createElement('option');
            y.text = this.isDobPicker && i < 10 ? "0" + i : i
            y.value = this.isDobPicker && i < 10 ? "0" + i : i
            try {
                if (i == this.initial_box_1) {
                    y.selected = true;
                }
                box.add(y, null); // standards compliant
            } 
            catch (ex) {
                if (i == this.initial_box_1) {
                    y.selected = true;
                }
                box.add(y); // IE only
            }
            
        }
        this.hour_box = box;
        return box;
    }
    
    
    this.createBox2 = function(){
        var box = document.createElement('select')
        box.onchange = eval(this.objectName + ".handleFocus")
        box.onclick = eval(this.objectName + ".handleFocus")
        box.id = "minBox"
        limit = this.isDobPicker ? 32 : 60
        start = this.isDobPicker ? 1 : 0
        for (i = start; i < limit; i++) {
            var y = document.createElement('option');
            
            y.text = i < 10 ? "0" + i : i
            y.value = i < 10 ? "0" + i : i
            
            try {
                if (i == this.initial_box_2) {
                    y.selected = true;
                }
                box.add(y, null); // standards compliant
            } 
            catch (ex) {
                if (i == this.initial_box_2) {
                    y.selected = true;
                }
                box.add(y); // IE only
            }
            
        }
        this.min_box = box;
        return box;
    }
    
    
    this.createYearBox = function(){
        var box = document.createElement('select')
        box.id = "dob_Yr_Box"
        curr_year = new Date().getFullYear();
        limit = curr_year - 150
        for (var i = curr_year; i >= limit; i--) {
            var y = document.createElement('option');
            y.text = i
            y.value = i
            try {
                box.add(y, null); // standards compliant
            } 
            catch (ex) {
                box.add(y); // IE only
            }
            if (i == this.initial_3) {
                y.selected = true;
            }
        }
        this.year_box = box;
        return box;
    }
    
    
    
    this.createAPBox = function(){
        var box = document.createElement('select')
        box.id = "am_box"
        var am = document.createElement('option');
        var pm = document.createElement('option');
        
        am.text = "AM"
        pm.text = "PM"
        am.value = "AM"
        pm.value = "PM"
        var blank = document.createElement('option');
        blank.text = "Select"
        blank.value = "";
        try {
            box.add(blank, null); // standards compliant
        } 
        catch (ex) {
            box.add(blank); // IE only
        }
        
        try {
            box.add(am, null); // standards compliant
        } 
        catch (ex) {
            box.add(am); // IE only
        }
        
        try {
            box.add(pm, null); // standards compliant
        } 
        catch (ex) {
            box.add(pm); // IE only
        }
        this.am_box = box;
        return box;
    }
    
    
    this.setFieldValue = function(event){
        cancelBubble(event)
        if (this.isDobPicker) {
            mon = this.hour_box.options[this.hour_box.selectedIndex].value;
            day = this.min_box.options[this.min_box.selectedIndex].value;
            year = this.year_box.options[this.year_box.selectedIndex].value;
            this.input.value = mon + "/" + day + "/" + year
        }
        else {
            if (this.am_box.value == "") {
                return;
            }
            hr = this.hour_box.options[this.hour_box.selectedIndex].value;
            min = this.min_box.options[this.min_box.selectedIndex].value;
            ap = this.am_box.options[this.am_box.selectedIndex].value;
            this.input.value = hr + ":" + min + " " + ap
        }
        
        if (!PositionFunctions.eventinRange(event, this.container_div)) {
            this.destroyTimePicker(event);
            
        }
        
    }
    
    
}


function addRequiredCalendarHTML(){
    table = document.createElement('table')
    table.className = "ds_box"
    table.cellPadding = "0"
    table.cellSpacing = "0"
    table.id = "ds_conclass"
    table.style.display = "none"
    row = table.insertRow(0);
    cell = row.insertCell(0);
    cell.id = "ds_calclass"
    
    body = document.getElementsByTagName('body')[0]
    body.appendChild(table);
    
}


Event.observe(window, 'load', addRequiredCalendarHTML);

