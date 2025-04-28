function toggleAnnotation(toggleElement) {
    hideAllAnnotations();
    const annotation = toggleElement.firstElementChild;
    if (annotation.classList.contains('hidden')) {
        annotation.classList.remove('hidden');
    } else {
        annotation.classList.add('hidden');
    }
}

function goAway(toggleElement) {
    toggleElement.classList.add('hidden');
}

// Add an event listener to hide all annotations when clicking anywhere on the page
document.addEventListener('click', function (event) {
    // Check if the clicked element is NOT an annotation or annotation-toggle
    if (!event.target.classList.contains('annotation') &&
        !event.target.classList.contains('annotation-toggle')) {
        // Hide all annotations
        hideAllAnnotations();
    }
});

function hideAllAnnotations() {
    const annotations = document.querySelectorAll('.annotation');
    annotations.forEach(function (annotation) {
        annotation.classList.add('hidden');
    });
}
