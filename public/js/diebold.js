$(".description-shower").click(function() {
	$(".collapse").addClass('in');
	$('.description-shower').addClass("hide");
	$('.description-hider').removeClass("hide");
});

$(".description-hider").click(function() {
  $(".collapse").removeClass('in');
  $('.description-hider').addClass("hide");
  $('.description-shower').removeClass("hide");
});

$("[rel=tooltip]").tooltip();
$('.timepicker-default').timepicker({showSeconds:true, defaultTime:'value',showMeridian:false,template:'dropdown'});


$("[data-toggle=buttons] input:checked").each(function() {
	if ($(this).parent('label')) {
		$(this).parent().addClass('active');
	}
})
