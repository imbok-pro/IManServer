CREATE OR REPLACE TYPE BODY SP.concat_agg_t
AS

    static function ODCIAggregateInitialize(sctx in out concat_agg_t)
        return number is
    begin
        sctx := concat_agg_t(null);
        return ODCIConst.Success;
    end;

    member function ODCIAggregateIterate(self in out concat_agg_t, value in varchar2)
        return number is
    begin
		if (str_agg is null) then
           str_agg := value;
		else
		   str_agg := str_agg || value;
		end if;

        return ODCIConst.Success;
    end;

    member function ODCIAggregateTerminate(self in concat_agg_t, return_value out varchar2, flags in number) return number is
    begin
        return_value := str_agg;
        return ODCIConst.Success;
    end;

    member function ODCIAggregateMerge(self in out concat_agg_t, ctx2 in concat_agg_t) return number is
    begin
		if (str_agg is null) then
           str_agg := ctx2.str_agg;
		else
		   str_agg := str_agg || ctx2.str_agg;
		end if;

        return ODCIConst.Success;
    end;
end;
/
