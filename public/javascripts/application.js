
// This file is automatically included by
// Needed to work around IE7's bug in redbox
// tied to custom link_to_function override in application_helper.rb
var IE = document.all ? true : false;

function GiveFalse(){
    if (IE) {
        event.returnValue = false;
    }
    return false;
}

 function change_select_box_value(ddlID, value) {
     var ddl = document.getElementById(ddlID);
     for (var i = 0; i < ddl.options.length; i++) {
         if (ddl.options[i].value == value) {
             if (ddl.selectedIndex != i) {
                 ddl.selectedIndex = i;
             }
             break;
         }
     }
 }
 
 function show_tool_tip(el_id,msg){
 	el = $(el_id)
	AjaxPopup.OpenBoxWithText(el,true,msg,null)
	pos = new PositionFunctions.getElementPosition(el);
    $('ajax_popup_box').style.top = pos.y + "px";
	
 }
 
document.observe("dom:loaded", function(){
    //	$$('select').each(function(item) {
    //		check_field(item);
    //	} );
    //	$$('input').each(function(item) {
    //		item.observe('click', check_field_event.bindAsEventListener());
    //		check_field(item);
    //	} );
    Ajax.Responders.register({
        onCreate: function(){
            if (Ajax.activeRequestCount > 0) 
                Element.show('form-indicator');
            $('form').disable();
        },
        onComplete: function(){
            if (Ajax.activeRequestCount == 0) 
                Element.hide('form-indicator');
            $('form').enable();
        }
    });
});

function radio_value(name){
    return Form.getInputs('form', 'radio', name).find(function(radio){
        return (radio.checked);
    }).value;
}

function check_field_event(event){
    check_field(Event.element(event));
}

function show(e){
    e = $(e);
    if (!e) {
        return false;
    }
    //e.show({duration: .01});
    e.show();
    field = e.select("input", "textarea").first();
    if (field) {
        field.focus();
    }
}

function hide(e){
    e = $(e);
    
    if (!e) {
        return false;
    }
    e.hide();
    //e.fade({duration: .05, from: 1, to: 0});
    field = e.select("input", "textarea").first();
    //	if (field) {
    //		field.clear();
    //	}
}

var details_fields = {};

function add_details_field(id, hide_on){
    details_fields[id] = hide_on;
}


function toggleEdit(){
	$$(".ut_edit_link").each(function(value, index) {
value.toggle();
});
placeTemplateLinks();
	
}




function check_field(e, value){

    //alert("credit value" +  $("article_submission_payment_type_credit").value);
    if (!e) {
        return false;
    }
    
    if (e.id.search(/degree1/) > -1) {
        value == 'Other' ? show($(e.id).next()) : hide($(e.id).next());
    }
    if (e.id.search(/degree2/) > -1) {
        value == 'Other' ? show($(e.id).next()) : hide($(e.id).next());
    }
    if (e.id.search(/degree3/) > -1) {
        value == 'Other' ? show($(e.id).next()) : hide($(e.id).next());
    }
    if (e.id.search(/contribution_type_other/) > -1) {
        value == -1 ? show($(e.id).next().next()) : hide($(e.id).next().next());
    }
    if (e.id.search(/update_credit_card/) > -1) {
        value == 1 ? show($('update_credit_card_div')) : hide($('update_credit_card_div'));
    }
    
    // specify the id of the field observed, and the state with which we hide the
    // details field
    details_fields = {
        "contribution_assisted": false,
        "contribution_agree_contents": true,
        "contribution_sole_submission": false,
        "contribution_received_payment": false,
        // "contribution_tobacco": false,
        "contribution_proprietary_guidelines": true,
        "contribution_agree_policies": true,
        "contribution_arynq2": true
    };
    
    for (id in details_fields) {
        if (e.id.search(new RegExp(id)) > -1) {
            if (radio_value(e.name) == details_fields[id]) {
                hide(id + "_span");
            }
            else {
                show(id + "_span");
            }
        }
    }
    
    if (e.id.search(new RegExp('tobacco')) > -1) {
        if (e.checked) {
            show("contribution_tobacco_span");
        }
        else {
            hide("contribution_tobacco_span");
        }
    }
    
    coi_details_fields = {
        "coi_form_employment": false,
        "coi_form_ip": false,
        "coi_form_consultant": false,
        "coi_form_honoraria": false,
        "coi_form_research": false,
        "coi_form_ownership": false,
        "coi_form_expert": false,
        "coi_form_other": false,
        "coi_form_alternative_use": false
    };
    
    /*  Now We're showing the COI conflicts questions all the time */
    /*
     if (e.id.search(/conflicts/) > -1) {
     if (value == 1) {
     show($('conflicts_group'));
     }
     else {
     hide($('conflicts_group'));
     $('conflicts_group').select('input').each(function(el){
     //				alert(el.id + "---" + el.value);
     el.value = null;
     el.checked = false;
     });
     $('conflicts_group').select('.details').each(function(el){
     el.hide();
     });
     }
     }*/
    has_reported_bias = false;
    for (id in coi_details_fields) {
    
        if (id != "coi_form_alternative_use" && $(id + "_1") && $(id + "_1").checked == true) {
            has_reported_bias = true;
            //			alert(id + "_1 is checked");
        }
        
        if (e.id.search(new RegExp(id)) > -1) {
            if (e.id.search(new RegExp('_1')) > -1) {
                if (details_fields[id] == true) {
                    hide(id + "_span");
                    //					alert("clicked on yes: hiding: " + e.id + "_span");
                }
                else {
                    show(id + "_span");
                    //					alert("clicked on yes: showing: " + e.id + "_span");
                }
            }
            else {
                if (details_fields[id] == true) {
                    show(id + "_span");
                    
                }
                else {
                    hide(id + "_span");
                }
            }
        }
    }
    
    // Not hiding questions on the auth respons. form anymore, commented out
    /** 
     if (e.id.search(/assisted/) > -1) {
     if (value == true) {
     show("auth_resp_remaining_questions");
     }
     else {
     hide("auth_resp_remaining_questions");
     }
     }
     **/
    if (e.id.search(/invited/) > -1) {
        if (value == true) {
            //			show("article_submission_invited_span");
            hide("article_submission_proffered_span");
        }
        else {
            show("article_submission_proffered_span");
            //			hide("article_submission_invited_span");
        }
    }
    
    if (e.id.search(/payment_type/) > -1) {
        if (value == 'check') {
            show("article_submission_payment_type_check_span");
            hide("article_submission_payment_type_credit_span");
            show("article_submission_fees_pubfee_status_span");
        }
        else 
            if (value == 'credit') {
                show("article_submission_payment_type_credit_span");
                show("article_submission_fees_pubfee_status_span");
                hide("article_submission_payment_type_check_span");
            }
            else {
                hide("article_submission_payment_type_credit_span");
                hide("article_submission_payment_type_check_span");
                hide("article_submission_fees_pubfee_status_span");
            }
    }
    
    if (e.id.search(/pubfee_status/) > -1) {
        if (value == 'cant_pay') {
            show("article_submission_cant_pay_reason_span");
            hide("article_submission_can_pay_span");
        }
        else {
            hide("article_submission_cant_pay_reason_span");
            show("article_submission_can_pay_span");
        }
    }
    
    //alert("after: credit value" +  $("article_submission_payment_type_credit").value);
}

function placeTemplateLinks(){
    if (window.templates) {
        var l = window.templates.length;
        for (var i = 0; i < l; i++) {
            $(window.templates[i] + '_edit_link').clonePosition($('ut_' + window.templates[i]), {
                setWidth: false,
                setHeight: false,
                offsetLeft: -10,
                offsetTop: -10
            });
        }
    }
    else {
        alert("There are no editable templates on this page.");
    }
}


function handleManuscriptTypes(){
    showGapAndLearn = $('article_submission_has_gap_and_learn_objs').checked
    if (showGapAndLearn) {
        $('extra_manuscript_fields').show();
    }
    else {
        $('extra_manuscript_fields').hide();
        empty_extra_man_fields()
    }
    
}


function empty_extra_man_fields(){
    fields = $('extra_manuscript_fields').getElementsBySelector('textarea');
    for (var index = 0; index < fields.length; ++index) {
        var item = fields[index];
        item.value = ""
    }
}






// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var PositionFunctions = {
    getleft: function(el){
        var tmp = el.offsetLeft;
        el = el.offsetParent
        while (el) {
            tmp += el.offsetLeft;
            el = el.offsetParent;
        }
        return tmp;
    },
    gettop: function(el){
        var tmp = el.offsetTop;
        el = el.offsetParent
        while (el) {
            tmp += el.offsetTop;
            el = el.offsetParent;
        }
        return tmp;
    },
    getElementPosition: function(el){
        this.x = PositionFunctions.getleft(el)
        this.y = PositionFunctions.gettop(el)
        this.element = el;
    },
    getPosRange: function(el){
        width = el.offsetWidth
        height = el.offsetHeight
        offsetLeft = PositionFunctions.getleft(el)
        offsetTop = PositionFunctions.gettop(el)
        this.start_x = offsetLeft;
        this.end_x = width + offsetLeft;
        this.start_y = offsetTop;
        this.end_y = height + offsetTop;
    },
    hiddenElements: new Array(),
    hideSelectBoxesUnderElement: function(parent){
        ieVer = PositionFunctions.ieVersion();
        if (ieVer == -1 || ieVer > 6) {
            return false;
        }
        selects = document.getElementsByTagName('select')
        for (var i = 0; i < selects.length; i++) {
            el = selects[i]
            if (PositionFunctions.itemUnderElement(new PositionFunctions.getElementPosition(el), parent)) {
                el.style.display = "none"
                PositionFunctions.hiddenElements.push(el)
            }
        }
    },
    ieVersion: function(){
        var rv = -1; // Return value assumes failure.
        if (navigator.appName == 'Microsoft Internet Explorer') {
            var ua = navigator.userAgent;
            var re = new RegExp("MSIE ([0-9]{1,}[\.0-9]{0,})");
            if (re.exec(ua) != null) 
                rv = parseFloat(RegExp.$1);
        }
        
        return rv;
    },
    showHiddenElements: function(){
        while (PositionFunctions.hiddenElements.length > 0) {
            el = PositionFunctions.hiddenElements.pop()
            el.style.display = ""
        }
        
    },
    itemUnderElement: function(pos, parent){
        if ($(pos.element).descendantOf(parent)) {
            return false;
        }
        
        range = new PositionFunctions.getPosRange(parent);
        x = pos.x
        y = pos.y
        op = ""
        op += pos.element.name + " : " + x + " : " + y + "\n"
        op += range.start_x + ":" + range.end_x + "/" + range.start_y + ":" + range.end_y
        overlaps_x = ((range.start_x) < x) && range.end_x > x
        overlaps_y = ((range.start_y) < y) && ((range.end_y) > y)
        return overlaps_x && overlaps_y;
    },
    eventinRange: function(e, el){
        range = new PositionFunctions.getPosRange(el)
        pos = new coords(e)
        x = pos.x
        y = pos.y
        op = ""
        op += pos.element.name + " : " + x + " : " + y + "\n"
        op += range.start_x + ":" + range.end_x + "/" + range.start_y + ":" + range.end_y
        overlaps_x = ((range.start_x) < x) && range.end_x > x
        overlaps_y = ((range.start_y) < y) && ((range.end_y) > y)
        return overlaps_x && overlaps_y;
    }
}





var AjaxPopup = {

    OpenBox: function(el, use_pos, before_call, after_call){
        if (before_call != null) {
            before_call();
        }
        
        AjaxPopup.CreateBox(el, use_pos);
        
        if (after_call != null) {
            after_call();
        }
        
        
    },
    OpenBoxWithText: function(el, use_pos, html, after_call){
    
        AjaxPopup.CreateBox(el, use_pos);
        if (after_call != null) {
            after_call();
        }
        $('ajax_popup_content').innerHTML = html;
    },
    OpenBoxWithContent: function(el, use_pos, after_call){
        AjaxPopup.CreateBox(el, use_pos);
        if (after_call != null) {
            after_call();
        }
        
        html = $('ajax_popup_content').innerHTML
        html = html.replace("class=\"template_text\"", "")
        $('ajax_popup_content').innerHTML = html;
    },
    
    OpenBoxWithUrl: function(el, use_pos, url, after_call, auto_width){
        AjaxPopup.CreateBox(el, use_pos);
        new Ajax.Request(url, {
            method: 'get',
            onSuccess: function(transport){
                html = transport.responseText;
                $('ajax_popup_content').innerHTML = html;
                
                if (after_call != null) {
                    after_call();
                }
                html = $('ajax_popup_content').innerHTML
                html = html.replace("class=\"template_text\"", "")
                $('ajax_popup_content').innerHTML = html;
            },
            onFailure: function(){
                $('ajax_popup_content').innerHTML = "Request Failed"
            }
        })
        
        
    },
    ajax_call: function(url){
        new Ajax.Request(url, {
            method: 'get',
            onSuccess: function(transport){
                html = transport.responseText;
                $('ajax_popup_content').innerHTML = html;
                
                if (after_call != null) {
                    after_call();
                }
            },
            onFailure: function(){
                $('ajax_popup_content').innerHTML = "Request Failed"
            }
        })
        
    },
    OpenModalBoxForUrl: function(el, use_pos, url, message, yes_text, no_text){
    
        AjaxPopup.CreateModalBox(el, use_pos, "Are You Sure You Want To Do This", yes_text, no_text, yes_method, no_method)
        
    },
    
    getCloseLink: function(){
        link_box = document.createElement('div')
        link_box.id = 'ajax_close_link_box'
        link = document.createElement('a');
        link.id = 'ajax_close_box_link'
        link.href = "javascript:void(0)";
        link.onclick = AjaxPopup.CloseWindow;
        link.innerHTML = "Close"
        link_box.appendChild(link)
        return link_box;
    },
    
    CloseWindow: function(){
        document.body.removeChild($('ajax_popup_box'))
        RedBox.close();
    },
    CreateBox: function(el, use_pos, no_close,show_close){
        if ($('ajax_popup_box')) {
            $('ajax_popup_box').remove();
        }
        container = document.createElement('div');
        container.id = "ajax_popup_box";
        box_content = document.createElement('div');
        box_content.id = "ajax_popup_content";
        spinner = new Image();
        spinner.id = "ajax_box_spinner"
        spinner.src = '../../images/spinner.gif';
        box_content.appendChild(spinner);
        container.appendChild(box_content);
        container.style.zIndex = 102;
        //container.style.position = "absolute";
        container.style.position = "fixed";
        if (no_close == null || !no_close) {
            container.appendChild(AjaxPopup.getCloseLink())
        }
        RedBox.showOverlay()
        $('RB_overlay').style.width = 2000 + "px"
        $('RB_overlay').style.height = 5000 + "px"
        document.body.appendChild(container);
        if (use_pos == true) {
			y_offset = show_close==null ? 700 : 100
            pos = new PositionFunctions.getElementPosition(el);
            y_pos = pos.y > 700 ? (pos.y - y_offset) : pos.y
            //container.style.top = y_pos + "px";
            container.style.top = "10px";
            container.style.left = "34%";
        }
        else {
            //container.style.top = "40%";
            container.style.top = "10px";
            container.style.left = "40%";
        }
        
        
    },
    
    CreateModalBox: function(el, use_pos, message, yes_text, no_text, yes_method, no_method, hide_close,make_close){
        AjaxPopup.CreateBox(el, use_pos, hide_close,make_close)
        div = document.createElement('div')
        div.style.textAlign = 'center'
        p = document.createElement('p')
        p.innerHTML = message
        div.appendChild(p)
        sp1 = document.createElement('span');
        sp2 = document.createElement('span');
        a1 = document.createElement('a');
        a2 = document.createElement('a');
        a1.href = "javascript:void(0)"
        a2.href = "javascript:void(0)"
        a1.onclick = function(){
            yes_method()
            AjaxPopup.CloseWindow()
        }
        a2.onclick = function(){
            no_method()
            AjaxPopup.CloseWindow()
        }
        a1.innerHTML = yes_text;
        a2.innerHTML = no_text;
        div.appendChild(sp1)
        div.appendChild(sp2)
        sp1.appendChild(a1);
        sp2.appendChild(a2);
        sp1.style.marginRight = '20px';
        $('ajax_popup_content').appendChild(div)
        $("ajax_box_spinner").hide();
        
    }
}


var FormFunctions = {

    disable_form_fields_in_section: function(el, section_id, disable_on,clear_value){
		value = FormFunctions.get_element_value(el)
        if (value != null) {
            arr = $(section_id).select('input', 'textarea');
	        for (i = 0; i < arr.length; i++) {
	            if (value == disable_on) {
				   FormFunctions.disable_and_clear_field($(arr[i]),clear_value)
	            }else {
	                $(arr[i]).enable()
	            }
	        }
		 }
    },
	
    disable_all_fields: function(el){
            arr = $(el).select('input', 'textarea');
	         for(i = 0; i < arr.length; i++) {
				   FormFunctions.disable_and_clear_field($(arr[i]),false)
	          
	        }

    },
    
    disable_and_clear_field: function(el,clear_value){
        el = $(el)
		el.disable();
        if(clear_value){
			FormFunctions.remove_value(el)
		}
        p_node = el.parentNode
        if (p_node.className == 'fieldWithErrors') {
            p_node.className = '';
        }
    },
    remove_field_values: function(section_id, el,remove_on){
        val = FormFunctions.get_element_value(el)
        if (val == remove_on) {
            arr = $(section_id).select('input', 'textarea');
            for (i = 0; i < arr.length; i++) {
			   FormFunctions.remove_value($(arr[i]))
            }
        }
    },	
	remove_value:function(el){
		  if (el.type == 'radio') {
             el[0].checked = false
             el[1].checked = false
          }else if (el.type == 'checkbox') {
             el.checked = false                           
		  }else if(el.type == 'text') {
             el.value = ""
          } 	
	}
    ,
    convert_to_text: function(section_id){
        arr = $(section_id).select('input', 'textarea');
        for (i = 0; i < arr.length; i++) {
            //prototype wonkiness
            el = $(arr[i])
            if (el.type != "hidden") {
                p = el.up()
                if (p != null) {
                    if (el.type == 'text') {
                        p.innerHTML = el.value
                    }
                    else 
                        if (el.type == 'radio') {
                            p.innerHTML = FormFunctions.get_radio_value(el)
                        }
                        else 
                            if (el.type == 'checkbox') {
                                p.innerHTML = el.checked ? "X" : ""
                                p.style.textAlign = 'center'
                            }
                    if (p.className == 'fieldWithErrors') {
                        p.className = ''
                    }
                    
                }
            }
        }
    },
	
	get_element_value:function(el){
		val = null
		 if (el.type =='checkbox'){
			val = el.checked
		}else if(!(el.length==undefined)){
			val = FormFunctions.get_radio_value(el)
		}else{
			val = el.value
		}
		return val
	},
	
    get_radio_value: function(el){
        val = null;
        for (k = 0; k < el.length; k++) {
            if (el[k].checked == true) {
                val = el[k].value;
                
            }
        }
        return val;
    },
    set_radio_value: function(el, val){
        for (k = 0; k < el.length; k++) {
            el[k].checked = el[k].value == val;
        }
    },
    enable_section_fields: function(section_id){
        arr = $(section_id).select('input', 'textarea');
        for (i = 0; i < arr.length; i++) {
            arr[i].enable()
        }
        return true;
    },
    
    
    uncheck_other: function(event){
        var el = Event.element(event);
        id = el.id
        if (id.include('uncomp')) {
            new_el = $(id.gsub('uncomp', 'comp'))
        }
        else {
            new_el = $(id.gsub('comp', 'uncomp'))
        }
        if (el.checked) {
            new_el.checked = !el.checked
        }
    }
    
}



var ArticleSubmissionFunctions = {

    handleFirstAuthorClick: function(el){
        if (el.checked) {
            boxes = $$('.first_author_box');
            for (var i = 0; i < boxes.length; i++) {
                box = boxes[i]
                if (box.id != el.id) {
                    box.checked = false;
                }
            }
        }
    },
    showIsLetter: function(el){
        if ($(el).value != null) {
            $('is_letter_row').show()
        }
        this.showPaymentBox(el, 'article_submission[is_letter]')
    },
    showPaymentBox: function(el, other){
        element = $(el)
        other = $('form')[other]
        this_val = element.value;
        other_val = FormFunctions.get_radio_value(other);
        if (this_val == false && other_val == false) {
            $('article_submission_proffered_span').show()
        }
        else {
            $('article_submission_proffered_span').hide()
        }
    },
    handleFeesPage: function(){
        el = $('form')['article_submission[invited]']
        invite_val = FormFunctions.get_radio_value(el)
        if (invite_val != null) {
            $('is_letter_row').show()
        }
    },
    sendRemoveCoAuthors: function(){
        url = "/manuscripts/remove_all_coauthors?id=" + ArticleSubmissionFunctions.as_id
        new Ajax.Request(url, {
            method: 'post',
            onFailure: function(){
                alert('Something went wrong...Please Try Again');
                AjaxPopup.CloseWindow()
            }
        });
    },
    as_id: "",
    removeCoauthors: function(el, id){
        ArticleSubmissionFunctions.as_id = id
        if ($(el).value == 1) {
            text = 'You currently have coauthors associated with this manuscript. Are you sure you want to remove them?';
            on_no = function(){
                AjaxPopup.CloseWindow();
                FormFunctions.set_radio_value($('form')['article_submission[sole_author]'], 0)
            }
            AjaxPopup.CreateModalBox(el, true, text, 'Yes', 'No', ArticleSubmissionFunctions.sendRemoveCoAuthors, on_no, true)
        }
        
    }
    
}

DisclosureFunctions = {

    get_role_boxes: function(){
        boxes = $$('input.coi_role');
    },  
	
	handle_has_conflicts:function(el){
		FormFunctions.disable_form_fields_in_section(el,'conflicts_group',false,true)
		DisclosureFunctions.check_role_fields()
	}
	,
    disable_disclosure_fields: function(el){
		 comp = $(el.id+"_comp")
		 uncomp = $(el.id+"_uncomp")
		 details = $(el.id+"_details")
        if (!el.checked) {
			FormFunctions.disable_and_clear_field(comp,true)
			FormFunctions.disable_and_clear_field(uncomp,true)   
			FormFunctions.disable_and_clear_field(details,true)      
        }else {
            comp.enable()
			uncomp.enable()
			details.enable()
        }      
    },
	
	check_role_fields:function(){
		boxes =  $$('input.coi_role');
        for(i=0;i<boxes.length;i++){
			DisclosureFunctions.disable_disclosure_fields(boxes[i])
		}  
	},
    set_coi_checkbox_events: function(){
        vals = ['employment', 'expert', 'ip', 'other', 'ownership', 'research', 'consultant', 'honoraria']
        pref = 'coi_form'
        comp = 'comp'
        uncomp = 'uncomp'
        for (i = 0; i < vals.length; i++) {
            val = vals[i]
            comp_el = $(pref + "_" + val + "_" + comp)
            uncomp_el = $(pref + "_" + val + "_" + uncomp)
            $(comp_el).observe('click', FormFunctions.uncheck_other)
            $(uncomp_el).observe('click', FormFunctions.uncheck_other)
            
        }
    }
    
}

 function send_to_cadmus(id){
		  url = '/admin/send_to_cadmus/'+id
	      new Ajax.Request(url, {asynchronous:true, evalScripts:true});
   }