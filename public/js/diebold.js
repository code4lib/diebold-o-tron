function show_hide(id) {  
    if (document.getElementById(id).style.display != 'block') {
        document.getElementById(id).style.display = 'block';
    } else {
        document.getElementById(id).style.display = 'none';
    }
}