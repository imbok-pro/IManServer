CREATE OR REPLACE PACKAGE SP.docPrjGen IS
  ------------------------------------------------------------------------
  -- docPrjGen package body
  -- by Gemba Sergey
  -- ����� ������������ ��� ��������� �������� - ��������� ����� ��� ������ � ����������� ��������� ����������
  -- create 03.09.2014
  -- update 03.09.2014
  ------------------------------------------------------------------------

  EOL CONSTANT CHAR(1) := CHR(13);

  -- ������� ������������ ��� ��������� �������: ����� ��� �������� ��������� ���������,
  --   ������ ��������� �� ������ ������ ������ (������� ���������� ����������)
  --   pi_marka_name - �������� �����
  --   pi_doc_prj_id - ������� ������ - ������� ��������� ��������� (#DocPrjHeaders)
  FUNCTION gen_marka_create_doc_header
  (
    pi_marka_name IN VARCHAR2,
    pi_doc_prj_id IN NUMBER,
    pi_model_name IN VARCHAR2 DEFAULT 'DocFlow||Documents'
  ) RETURN sp.tsource
    PIPELINED;

  -- ������� ������������ ��� ��������� ������� - ���� �����������, �� ������ ������ ������ ������������ �������� ���������� ����������(#CodeSectorRefs)
  --   pi_ref_name - �������� ����������� (�������� NAME ������� #CodeSectorRefs)
  FUNCTION gen_type_for_ref(pi_ref_name IN VARCHAR2, pi_model_name IN VARCHAR2 DEFAULT 'DocFlow||Documents') RETURN sp.tsource
  PIPELINED;
END;
/
