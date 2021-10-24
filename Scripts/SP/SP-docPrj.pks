CREATE OR REPLACE PACKAGE SP.docPrj IS
  ------------------------------------------------------------------------
  -- docPrj package
  -- by Gemba Sergey
  -- create 03.09.2014
  -- update 03.09.2014
  ------------------------------------------------------------------------
  -- ������� �������� �������� ���������
  --   pi_mod_obj_id - id ������ (���� sp.models.id)
  --   pi_param_name - �������� ��������� ������� ������
  FUNCTION get_param_value(pi_mod_obj_id IN NUMBER,
                           pi_param_name IN VARCHAR2) RETURN VARCHAR2;

  -- ������� ���������� ���������� ��������� ��� ������� ��������� � �����
  --   pi_doc_prj_id - id ������ (���� sp.models.id )
  --   return - ���������� ��������� ��� ������� ��������� ���������
  FUNCTION build_regexp(pi_doc_prj_id IN NUMBER,
                        pi_model_name IN VARCHAR2 DEFAULT 'DocFlow||Documents') 
  RETURN VARCHAR2;

  -- ������� ������������ ��� ����������� ��������� ���������,
  --  pi_doc_header - ��������� ���������
  --  po_text_out - �������� ��������,  ��������� � ���� ���������� ���������:
  --        � ������ ��������� ����������� ������������ ������� - ��������� ������������ ����� �������,
  --        ����� �������� ������
  PROCEDURE find_doc_template(pi_doc_header IN VARCHAR2, po_text_out OUT VARCHAR2, pi_model_name IN VARCHAR2 DEFAULT 'DocFlow||Documents');
END;
/
