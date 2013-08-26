function show_hide(id) {  
    if (document.getElementById(id).style.display != 'block') {
        document.getElementById(id).style.display = 'block';
    } else {
        document.getElementById(id).style.display = 'none';
    }
}

$(".description-shower").click(function() {
	$(".description").show();
	$('.description-shower').hide();
	$('.description-hider').show();
});

$(".description-hider").click(function() {
	$(".description").hide();
	$('.description-hider').hide();
	$('.description-shower').show();
});
$(".item_title").click(function(){
	var id = $(this).attr('id').split("_").pop();
	var myId = "#election_item_description_" + id;
	if($(myId).is(':hidden'))
	{
		$(myId).show();
	} else {
		$(myId).hide();
	}
});
$(".rating-score").click(function(){
    var idParts = $(this).attr('id').split("_");
    var myId = "#item\\["+idParts[1]+"\\]";
    $(myId).attr('value', $(this).attr('value'));
})
//$('.collapse').collapse();
$("[rel=tooltip]").tooltip();
$('.timepicker-default').timepicker({showSeconds:true, defaultTime:'value',showMeridian:false,template:'dropdown'});