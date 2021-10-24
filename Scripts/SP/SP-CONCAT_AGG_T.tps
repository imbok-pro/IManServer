CREATE OR REPLACE TYPE SP.CONCAT_AGG_T                                                                                                                                                   as object (

    str_agg varchar2(4000),

    static function ODCIAggregateInitialize(sctx  in out concat_agg_t)
                    return number,

    member function ODCIAggregateIterate   (self  in out concat_agg_t,
                                            value in varchar2 )
                    return number,

    member function ODCIAggregateTerminate (self         in     concat_agg_t   ,
                                            return_value    out varchar2,
                                            flags        in number      )
                    return number,

    member function ODCIAggregateMerge(self in out concat_agg_t,
                                       ctx2 in concat_agg_t    )
                    return number
)
/
