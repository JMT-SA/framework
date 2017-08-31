// const sMenu = (function(){
(function(){
    function qsl(selector, context){
        context = context || document;
        return context["querySelectorAll"](selector);
    }

    function forEach(collection, iterator){
        for(var key in Object.keys(collection)){
            iterator(collection[key]);
        }
    }

    function showMenu(menu){
      // var menu = this;
        var ul = qsl("ul", menu)[0];
      // var ul = menu.querySelector('ul');

        if(!ul || ul.classList.contains("-visible")) return;

        menu.classList.add("-active");
        ul.classList.add("-animating");
        ul.classList.add("-visible");
        setTimeout(function(){
            ul.classList.remove("-animating")
        }, 25);
    }

    function hideMenu(menu){
      // var menu = this;
        var ul = qsl("ul", menu)[0];

        if(!ul || !ul.classList.contains("-visible")) return;

        menu.classList.remove("-active");
        ul.classList.add("-animating");
        setTimeout(function(){
            ul.classList.remove("-visible");
            ul.classList.remove("-animating");
        }, 300);
    }

    function hideAllInactiveMenus(menu){
      // var menu = this;
        forEach(
            qsl("li.-hasSubmenu.-active:not(:hover)", menu.parent),
            function(e){
              // e.hideMenu && e.hideMenu();
              hideMenu(e);
            }
        );
    }

    // window.addEventListener("load", function(){
    //     forEach(qsl(".Menu li.-hasSubmenu"), function(e){
    //         e.showMenu = showMenu;
    //         e.hideMenu = hideMenu;
    //     });
    //
    //     forEach(qsl(".Menu > li.-hasSubmenu"), function(e){
    //         e.addEventListener("click", showMenu);
    //     });
    //
    //     forEach(qsl(".Menu > li.-hasSubmenu li"), function(e){
    //         e.addEventListener("mouseenter", hideAllInactiveMenus);
    //     });
    //
    //     forEach(qsl(".Menu > li.-hasSubmenu li.-hasSubmenu"), function(e){
    //         e.addEventListener("mouseenter", showMenu);
    //     });
    //
    //     document.addEventListener("click", hideAllInactiveMenus);
    // });

  /** TODO: 
   * 1. open submenus on hover. (mouseenter : maybe use datalist instead of class to recognise)
   * 2. Clean up code and move into crossbeamsMenu.
   */

    document.addEventListener('DOMContentLoaded', () => {
      document.body.addEventListener("click", hideAllInactiveMenus);
      document.body.addEventListener('click', (event) => {
        if (event.target.parentNode && event.target.parentNode.classList.contains('-hasSubmenu')) {
          showMenu(event.target.parentNode);
          event.stopPropagation();
          event.preventDefault();
        }
      });
      // document.body.addEventListener('mouseenter', (event) => {
      //   if (event.target.parentNode.classList.contains('-hasSubmenu')) {
      //     showMenu(event.target.parentNode);
      //     event.stopPropagation();
      //     event.preventDefault();
      //   }
      // });
        // forEach(qsl(".Menu > li.-hasSubmenu li"), function(e){
        //     e.addEventListener("mouseenter", hideAllInactiveMenus);
        // });
        //
        // forEach(qsl(".Menu > li.-hasSubmenu li.-hasSubmenu"), function(e){
        //     e.addEventListener("mouseenter", showMenu);
        // });
    });
})();
