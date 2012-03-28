$(document).ready(function(){
   $('a[rel=tooltip]').tooltip()
   
   $("a.grouped_elements").fancybox({
       
       'overlayShow'	: false,
       'autoScale'		: true,
       'transitionIn'	: 'elastic',
       'transitionOut'	: 'elastic'
   });
 });