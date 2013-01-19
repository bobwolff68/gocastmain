var RegisterView = {
    $forms: {},
    init: function() {
        for (var i=0; i<document.forms.length; i++) {
            this.$forms[document.forms[i].id] = $(document.forms[i]);
        }
        this.displaydefaultform($.urlvars.defaultaction);
    },
    displayform: function(id) {
        for (i in this.$forms) {
            this.$forms[i].removeClass('show');
            $('.alert', this.$forms[i]).removeClass('show');
        }
        this.$forms[id].addClass('show');
    },
    displaydefaultform: function(action) {
        var actions = ['register', 'activate'];
        var formids = {register: 'register-form', activate: 'activate-form'};

        if (!action || -1 === actions.indexOf(action)) {
            this.displayform('register-form');
        } else {
            this.displayform(formids[action]);
        }
    },
    displayalert: function(formid, type, message) {
        var $alert = null;

        $('.alert', this.$forms[formid]).removeClass('show');
        $alert = $('.alert-' + type, this.$forms[formid]).addClass('show');
        $('p', $alert).html(message);
    }
};

var RegisterApp = {
    $forms: {},
    formSubmitResultCallbacks: {
        'register-form': {
            success: function() {
                return function(response) {
                    if ('success' === response.result) {
                        RegisterView.displayform('activate-form');
                        RegisterView.displayalert('activate-form', 'success', 'Your account has been created. ' +
                                                'An activation email has been sent to the address you just provided. ' +
                                                'Follow the instructions in the email to activate your account.');
                    } else if ('inuse' === response.result) {
                        RegisterView.displayalert('register-form', 'error', 'An account for the email address you\'ve provided ' +
                                                'already exists. Choose a different email address.');
                        $('#input-email', RegisterApp.$forms['register-form']).focus();
                    } else {
                        RegisterView.displayalert('register-form', 'error', 'There was a problem signing up for your new account.');
                    }
                };
            },
            failure: function() {
                return function(error) {
                    RegisterView.displayalert('register-form', 'error', 'There was a problem signing up for your new account.');
                };
            }
        },
        'activate-form': {
            success: function() {
                return function(response) {
                    if ('success' === response.result) {
                        window.location.href = $.urlvars.baseurl
                                                .replace(/register\.html/, 'dashboard.html')
                                                + '?justactivated=true';
                    } else if ('incorrect' === response.result) {
                        RegisterView.displayalert('activate-form', 'error', 'The activation code you\'ve provided is wrong. ' +
                                                'Please provide the correct activation code.');
                        $('#input-activation-code', $RegisterApp.$forms['activate-form']).val('').focus();
                    } else if ('noaccount' === response.result) {
                        RegisterView.displayalert('activate-form', 'error', 'The activation code you\'ve provided is bad. ' +
                                                'There is no account for the email address you\'ve provided.');
                        $('#input-email', $RegisterApp.$forms['activate-form']).focus();
                    } else if ('usedorexpired' === response.result) {
                        RegisterView.displayalert('activate-form', 'error', 'The activation code you\'ve provided has expired ' +
                                                'or has already been used to activate your account.');
                        $('#input-email', $RegisterApp.$forms['activate-form']).focus();
                    } else {
                        RegisterView.displayalert('activate-form', 'error', 'There was a problem activating your account.');
                    }
                };
            },
            failure: function() {
                return function(error) {
                    RegisterView.displayalert('activate-form', 'error', 'There was a problem activating your account.');
                };
            }
        }
    },
    init: function() {
        var urlvars = $.urlvars,
            self = this;

        for (var i=0; i<document.forms.length; i++) {
            var options = {
                dataType: 'json',
                resetForm: true,
                success: this.formSubmitResultCallbacks[document.forms[i].id].success(),
                error: this.formSubmitResultCallbacks[document.forms[i].id].failure()        
            };

            if ('register-form' === document.forms[i].id) {
                options.data = {baseurl: urlvars.baseurl};
                options.beforeSubmit = function(arr, $form, options) {
                    $('#input-email', self.$forms['activate-form']).val($('#input-email', $form).val());
                    if ($('#input-password', $form).val() !== $('#input-confirm-password', $form).val()) {
                        RegisterView.displayalert('register-form', 'error', 'The password fields don\'t match. Make sure ' +
                                                'you\'ve entered the same password in both fields.');
                        $('#input-password', $form).focus();
                        return false;
                    }
                };
            }
            this.$forms[document.forms[i].id] = $(document.forms[i]);
            this.$forms[document.forms[i].id].ajaxForm(options);
        }

        if ('activate' === urlvars.defaultaction && urlvars.code && urlvars.email) {
            $('#input-email', this.$forms['activate-form']).val(urlvars.email);
            $('#input-activation-code', this.$forms['activate-form']).val(urlvars.code);
            $('[type="submit"].btn', this.$forms['activate-form']).click();
        }
    }
};

$(document).ready(function() {
    RegisterView.init();
    RegisterApp.init();
});