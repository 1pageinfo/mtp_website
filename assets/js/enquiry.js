/**
 * enquiry.js — Handles all enquiry form submissions via AJAX
 * Works for both:
 *   1. #contact-form  (contact-us.html)
 *   2. #quote-form    (modal on all service + grade pages)
 */
(function () {
    'use strict';

    // Resolve correct PHP endpoint for root vs grades/ subdirectory
    var isGrade = window.location.pathname.indexOf('/grades/') !== -1;
    var endpoint = isGrade ? '../send-enquiry.php' : 'send-enquiry.php';

    function submitForm(form, msgBoxId, defaultBtnText) {
        form.addEventListener('submit', function (e) {
            e.preventDefault();

            var msgBox = document.getElementById(msgBoxId);
            var btn    = form.querySelector('button[type="submit"]');

            // Clear previous message
            msgBox.style.display = 'none';
            msgBox.textContent   = '';

            // Disable button while sending
            btn.disabled    = true;
            btn.textContent = 'Sending\u2026';

            var data = new FormData(form);
            data.append('page_source', window.location.href);

            fetch(endpoint, { method: 'POST', body: data })
                .then(function (response) {
                    return response.json();
                })
                .then(function (res) {
                    msgBox.style.display      = 'block';
                    msgBox.style.padding      = '8px 12px';
                    msgBox.style.borderRadius = '4px';
                    msgBox.style.fontSize     = '14px';
                    if (res.success) {
                        msgBox.style.background = '#e8f5e9';
                        msgBox.style.color      = '#2e7d32';
                        msgBox.style.border     = '1px solid #a5d6a7';
                        msgBox.textContent      = res.message;
                        form.reset();
                    } else {
                        msgBox.style.background = '#ffebee';
                        msgBox.style.color      = '#c62828';
                        msgBox.style.border     = '1px solid #ef9a9a';
                        msgBox.textContent      = res.message;
                    }
                })
                .catch(function () {
                    msgBox.style.display      = 'block';
                    msgBox.style.padding      = '8px 12px';
                    msgBox.style.borderRadius = '4px';
                    msgBox.style.fontSize     = '14px';
                    msgBox.style.background   = '#ffebee';
                    msgBox.style.color        = '#c62828';
                    msgBox.style.border       = '1px solid #ef9a9a';
                    msgBox.textContent        = 'Network error. Please try again.';
                })
                .finally(function () {
                    btn.disabled    = false;
                    btn.textContent = defaultBtnText;
                });
        });
    }

    // Contact page form
    var contactForm = document.getElementById('contact-form');
    if (contactForm) {
        submitForm(contactForm, 'contact-form-msg', 'Submit Inquiry');
    }

    // Modal quote form
    var quoteForm = document.getElementById('quote-form');
    if (quoteForm) {
        submitForm(quoteForm, 'quote-form-msg', 'SEND MESSAGE');
    }

})();
