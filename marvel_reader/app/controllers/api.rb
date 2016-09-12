module Api

    # Success codes
    RETURN_CODE_OK = 0.freeze

    # Error codes

    RETURN_CODE_UNKNOWN_ERROR           = -100000.freeze
    RETURN_CODE_PARAM_MISSING           = -100001.freeze
    RETURN_CODE_RECORD_NOT_FOUND        = -100002.freeze

    RETURN_CODE_UNKNOWN_USER            = -200000.freeze
    RETURN_CODE_RESET_PERIOD_INVALID    = -200001.freeze
    RETURN_CODE_UNCONFIRMED_USER        = -200002.freeze
    RETURN_INVALID_USER                 = -200003.freeze

    RETURN_CODE_INVALID_CREDENTIALS     = -300000.freeze
    RETURN_CODE_FORBIDDEN_URL           = -300001.freeze

    RETURN_CODE_MODEL_SAVE              = -400000.freeze

end