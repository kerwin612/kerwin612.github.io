

$(window).scroll(function() {

	if ($(window).scrollTop() > 44) {
				$('.main-menu').addClass("active");
				$('header').addClass("active");
	}
	else{
		$('.main-menu').removeClass("active");
		$('header').removeClass("active");
	}
});

//  if (screen.width > 1024) {
// if ( $('.portipolio-sec').length > 0 ) {

//    AOS.init({
//         easing: 'ease-in-out-sine'
//       });
// }
//  }

if ( $('.videos-sec').length > 0 ) {
	$.wmBox();
}



