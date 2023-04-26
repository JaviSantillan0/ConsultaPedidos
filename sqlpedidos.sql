SELECT 
  CUPOS.CUP_ESTADO, 
  CUPOS.CUP_NUMERO, 
  NVL(CUPOS.CUP_PLANTA_ORIGEN, 0) AS CUP_PLANTA_ORIGEN, 
  PLANTAS.PLA_DESCRIPCION, 
  CUPOS.CUP_PRODUCTOR, 
  ENTIDAD_PRODUCTOR.ENT_NOMBRE as Nombre_Productor, 
  CUPOS.CUP_FECHA_ENTREGA, 
  CUPOS.CUP_DESTINO, 
  PROCEDENCIAS_DESTINOS.PDE_DESCRIPCION, 
  CONTRATOS.CNT_NUMERO, 
  CONTRATOS.CNT_VENDEDOR, 
  ENTIDADES.ENT_NOMBRE Nombre_Comprador, 
  CONTRATOS.CNT_ESPECIE, 
  CONTRATOS.CNT_COSECHA, 
  CONTRATOS.CNT_KILOS_PROMEDIO, 
  CONTRATOS.CNT_FECHA_DESDE_ENTREGAS, 
  CUP_TIPO_CARTA_PORTE, 
  TO_CHAR(
    NVL(CUP_SUCURSAL_CARTA_PORTE, 0), 
    'fm0000'
  ) AS CUP_SUCURSAL_CARTA_PORTE, 
  TO_CHAR(
    NVL(CUP_NUMERO_CARTA_PORTE, 0), 
    'fm000000000000'
  ) AS CUP_NUMERO_CARTA_PORTE, 
  CUP_RENGLON_CARTA_PORTE, 
  CEIL (
    (
      CONTRATOS.CNT_KILOS_PROMEDIO + NVL (
        CONTRATOS.CNT_KILOS_EXCEDENTES, 
        0
      ) - NVL(APLICADO.TOTAL_NETO, 0) - NVL(
        APLICADO.TOTAL_ENVIADO_SIN_DESCARGAR, 
        0
      ) - NVL(
        APLICADO.KILOS_CUPOS_CUMP_PENDIENTES, 
        0
      )
    ) / TRANS_ESPE.KILOS_X_CUPO
  ) AS CANTIDAD_CUPOS, 
  CEIL (
    (
      CONTRATOS.CNT_KILOS_PROMEDIO + NVL (
        CONTRATOS.CNT_KILOS_EXCEDENTES, 
        0
      ) - NVL(APLICADO.TOTAL_NETO, 0) - NVL(
        APLICADO.TOTAL_ENVIADO_SIN_DESCARGAR, 
        0
      ) - NVL(
        APLICADO.KILOS_CUPOS_CUMP_PENDIENTES, 
        0
      )
    ) / TRANS_ESPE.KILOS_X_CUPO
  ) - NVL(USADOS, 0) AS CUPOS_RESTANTES, 
  CONTRATOS.CNT_DESTINO, 
  PROCEDENCIAS_DESTINOS_CNT.PDE_DESCRIPCION, 
  NO_USADOS, 
  NULL AS COMPROBANTE_COMPRA, 
  CUPOS.CUP_NUMERO_EXTERNO, 
  TRIM(CORREDORES.ENT_CODIGO) || ' ' || CORREDORES.ENT_NOMBRE AS CORREDOR, 
  NULL, 
  CUPOS.CUP_DESCRIPCION_CANCELACION, 
  OTORGADOS.TOTAL_CUPOS_OTORGADOS, 
  CONTRATOS_COMPRA.CNT_VENDEDOR || ' ' || VENDEDOR_CONTRATOS_COMPRA.ENT_NOMBRE VENDEDOR_CTO_COMPRA, 
  TO_CHAR(
    PEDIDOS_FLETE_CAMIONES.PFC_PUNTO_EGRESO_BALANZA, 
    'fm0000'
  ) || '-' || TO_CHAR(
    PEDIDOS_FLETE_CAMIONES.PFC_NUMERO_EGRESO_BALANZA, 
    'fm00000000'
  ) AS NRO_EGRESO, 
  TRIM (ENTIDAD_ENTREGADOR.ENT_CODIGO)|| ' ' || ENTIDAD_ENTREGADOR.ENT_NOMBRE ENTREGADOR, 
  CONTRATOS.CNT_PROCEDENCIA || ' ' || PROCEDENCIA_CNT.PDE_DESCRIPCION AS PROCEDENCIA_CNT, 
  TRIM (
    CAMPOS.CAM_CAMPO || ' ' || CAMPOS.CAM_DESCRIPCION
  ) AS CAMPO, 
  CUPOS.CUP_FECHA_ASIGNACION, 
  CONTRATO_COMPRA_EGRESO.CNT_NUMERO AS NRO_CTTO_COMPRA, 
  TRIM (
    CORREDOR_CONTRATO_COMPRA.ENT_CODIGO
  ) AS COD_CORREDOR_CTTO_COMPRA, 
  CORREDOR_CONTRATO_COMPRA.ENT_NOMBRE AS CORREDOR_CTTO_COMPRA, 
  TRIM (
    VENDEDOR_CONTRATO_COMPRA.ENT_CODIGO
  ) AS COD_VENDEDOR_CTTO_COMPRA, 
  VENDEDOR_CONTRATO_COMPRA.ENT_NOMBRE AS VENDEDOR_CTTO_COMPRA 
FROM 
  CUPOS, 
  CONTRATOS, 
  ENTIDADES, 
  ENTIDADES ENTIDAD_PRODUCTOR, 
  PROCEDENCIAS_DESTINOS, 
  PLANTAS, 
  PROCEDENCIAS_DESTINOS PROCEDENCIAS_DESTINOS_CNT, 
  ENTIDADES CORREDORES, 
  CONTRATOS CONTRATOS_COMPRA, 
  ENTIDADES VENDEDOR_CONTRATOS_COMPRA, 
  (
    SELECT 
      CONTRATOS.CNT_TIPO_CONTRATO, 
      CONTRATOS.CNT_NUMERO, 
      NVL (
        SUM (
          CARTAS_DE_PORTE.CPE_KILOS_BRUTOS
        ), 
        0
      ) AS TOTAL_BRUTO, 
      SUM(
        DECODE(
          CPE_KILOS_NETOS, 
          NULL, 
          CPE_KILOS_ENVIADOS, 
          0, 
          CPE_KILOS_ENVIADOS, 
          ROUND(
            (
              (
                APLICACIONES.APC_KILOS_NETOS * CARTAS_DE_PORTE.CPE_KILOS_ENVIADOS
              ) / CARTAS_DE_PORTE.CPE_KILOS_NETOS
            ), 
            0
          )
        )
      ) AS TOTAL_ENVIADO, 
      NVL (
        SUM (
          APLICACIONES.APC_KILOS_DESCARGADOS
        ), 
        0
      ) AS TOTAL_DESCARGADO, 
      NVL (
        SUM (
          APLICACIONES.APC_KILOS_MERMA_HUMEDAD
        ), 
        0
      ) AS TOTAL_HUMEDAD, 
      NVL (
        SUM (
          APLICACIONES.APC_KILOS_MERMA_ZARANDEO
        ), 
        0
      ) AS TOTAL_ZARANDEO, 
      NVL (
        SUM (
          APLICACIONES.APC_KILOS_MERMA_VOLATIL
        ), 
        0
      ) AS TOTAL_VOLATIL, 
      NVL (
        SUM (APLICACIONES.APC_KILOS_NETOS), 
        0
      ) AS TOTAL_NETO, 
      NVL(
        SUM(
          DECODE(
            CPE_KILOS_NETOS, NULL, CPE_KILOS_ENVIADOS, 
            0
          )
        ), 
        0
      ) AS TOTAL_ENVIADO_SIN_DESCARGAR, 
      NVL(
        SUM(
          DECODE(
            NVL(TNE_PRESTAMO, 'No'), 
            'Sí', 
            APLICACIONES.APC_KILOS_NETOS * DECODE(
              SIGN(APLICACIONES.APC_KILOS_NETOS), 
              -1, 
              0, 
              1
            ), 
            0
          )
        ), 
        0
      ) AS TOTAL_NETO_ENTREGADO, 
      NVL(
        SUM(
          DECODE(
            NVL(TNE_PRESTAMO, 'No'), 
            'Sí', 
            APLICACIONES.APC_KILOS_NETOS * DECODE(
              SIGN(APLICACIONES.APC_KILOS_NETOS), 
              -1, 
              1, 
              0
            ) * (-1), 
            0
          )
        ), 
        0
      ) AS TOTAL_NETO_RECIBIDO, 
      NVL(
        VISTA_CUPOS.KILOS_CUPOS_ASIGNADOS, 
        0
      ) AS KILOS_CUPOS_ASIGNADOS, 
      NVL(
        VISTA_CUPOS.KILOS_CUPOS_APLICADOS, 
        0
      ) AS KILOS_CUPOS_APLICADOS, 
      NVL(
        VISTA_CUPOS.KILOS_CUPOS_CUMP_PENDIENTES, 
        0
      ) AS KILOS_CUPOS_CUMP_PENDIENTES, 
      NVL(
        VISTA_CUPOS.KILOS_CUPOS_SIN_ASIGNAR, 
        0
      ) AS KILOS_CUPOS_SIN_ASIGNAR 
    FROM 
      CONTRATOS, 
      APLICACIONES, 
      CARTAS_DE_PORTE, 
      TIPOS_NEGOCIO, 
      (
        SELECT 
          DETALLE_CUPOS.TIPO_CONTRATO, 
          DETALLE_CUPOS.NUMERO_CONTRATO, 
          NULL AS KILOS_X_CUPO, 
          COUNT(DETALLE_CUPOS.CUP_NUMERO) AS CANTIDAD_CUPOS, 
          ROUND (
            SUM(
              NVL(DETALLE_CUPOS.KILOS_X_CUPO, 0) * DECODE (
                DETALLE_CUPOS.CUP_ESTADO, 'A', 1, 
                'D', 1, 0
              )
            ), 
            0
          ) AS TOT_KILOS_CUPOS_APLI, 
          SUM(
            DECODE(
              DETALLE_CUPOS.CUP_ESTADO, 'A', 1, 
              0
            )
          ) AS CANTIDAD_CUPOS_ASIGNADOS, 
          SUM(
            DECODE(
              DETALLE_CUPOS.CUP_ESTADO, 'D', 1, 
              0
            )
          ) AS CANTIDAD_CUPOS_APLICADOS, 
          ROUND (
            SUM(
              NVL (DETALLE_CUPOS.KILOS_X_CUPO, 0) * DECODE(
                DETALLE_CUPOS.CUP_ESTADO, 'A', 1, 
                0
              )
            ), 
            0
          ) AS KILOS_CUPOS_ASIGNADOS, 
          ROUND (
            SUM(
              NVL (DETALLE_CUPOS.KILOS_X_CUPO, 0) * DECODE(
                DETALLE_CUPOS.CUP_ESTADO, 'D', 1, 
                0
              )
            ), 
            0
          ) AS KILOS_CUPOS_APLICADOS, 
          SUM(
            DECODE (
              DETALLE_CUPOS.CUP_ESTADO, 'U', 1, 
              0
            )
          ) AS CANTIDAD_CUPOS_CUMP_PENDIENTES, 
          ROUND(
            SUM(
              NVL(
                DETALLE_CUPOS.INE_KILOS_NETOS, 0
              ) * DECODE (
                DETALLE_CUPOS.CUP_ESTADO, 'U', 1, 
                0
              )
            ), 
            0
          ) AS KILOS_CUPOS_CUMP_PENDIENTES, 
          ROUND(
            SUM(
              NVL(DETALLE_CUPOS.KILOS_X_CUPO, 0) * DECODE (
                DETALLE_CUPOS.CUP_ESTADO, 'S', 1, 
                0
              )
            ), 
            0
          ) AS KILOS_CUPOS_SIN_ASIGNAR, 
          SUM (
            DECODE (
              DETALLE_CUPOS.CUP_ESTADO, 'S', 1, 
              0
            )
          ) AS CANTIDAD_CUPOS_SIN_ASIGNAR 
        FROM 
          (
            SELECT 
              CONTRATOS.CNT_TIPO_CONTRATO AS TIPO_CONTRATO, 
              CONTRATOS.CNT_NUMERO AS NUMERO_CONTRATO, 
              NVL(
                KILOS_TRANSPORTE.KILOS_X_CUPO, 0
              ) AS KILOS_X_CUPO, 
              CUPOS.CUP_NUMERO, 
              CUPOS.CUP_ESTADO, 
              INTERFAZ_ENTREGADORES.INE_KILOS_NETOS 
            FROM 
              CONTRATOS, 
              CUPOS, 
              INTERFAZ_ENTREGADORES, 
              TIPOS_NEGOCIO, 
              (
                SELECT 
                  TRANSPORTES_ESPECIES.TRANSPORTE, 
                  TRANSPORTES_ESPECIES.ESPECIE, 
                  NVL(
                    CUPOS_PARAMETROS.CPS_TONELADAS, 
                    CUPOS_TRANSPORTE.CT_TONELADAS
                  ) * 1000 AS KILOS_X_CUPO 
                FROM 
                  CUPOS_PARAMETROS, 
                  (
                    SELECT 
                      ESPECIES.ESP_ESPECIE AS ESPECIE, 
                      TIPOS_TRANSPORTES.TRANSPORTE 
                    FROM 
                      ESPECIES, 
                      (
                        SELECT 
                          DISTINCT CUPOS_PARAMETROS.CPS_TIPO_TRANSPORTE AS TRANSPORTE 
                        FROM 
                          CUPOS_PARAMETROS
                      ) TIPOS_TRANSPORTES
                  ) TRANSPORTES_ESPECIES, 
                  (
                    SELECT 
                      CUPOS_PARAMETROS.CPS_TIPO_TRANSPORTE AS CT_TRANSPORTE, 
                      CUPOS_PARAMETROS.CPS_TONELADAS AS CT_TONELADAS 
                    FROM 
                      CUPOS_PARAMETROS 
                    WHERE 
                      CUPOS_PARAMETROS.CPS_ESPECIE IS NULL
                  ) CUPOS_TRANSPORTE 
                WHERE 
                  TRANSPORTES_ESPECIES.TRANSPORTE = CUPOS_TRANSPORTE.CT_TRANSPORTE (+) 
                  AND TRANSPORTES_ESPECIES.TRANSPORTE = CUPOS_PARAMETROS.CPS_TIPO_TRANSPORTE(+) 
                  AND TRANSPORTES_ESPECIES.ESPECIE = CUPOS_PARAMETROS.CPS_ESPECIE(+)
              ) KILOS_TRANSPORTE 
            WHERE 
              CUPOS.CUP_TIPO_CONTRATO = CONTRATOS.CNT_TIPO_CONTRATO 
              AND CUPOS.CUP_NUMERO_CONTRATO = CONTRATOS.CNT_NUMERO 
              AND NVL(CUPOS.CUP_TIPO_CUPO, 'C') = 'C' 
              AND CONTRATOS.CNT_ESPECIE = KILOS_TRANSPORTE.ESPECIE(+) 
              AND DECODE(
                CONTRATOS.CNT_TIPO_TRANSPORTE, 
                'Ambos', 
                NVL(
                  CUPOS.CUP_TIPO_TRANSPORTE, 'Camión'
                ), 
                CONTRATOS.CNT_TIPO_TRANSPORTE
              ) = KILOS_TRANSPORTE.TRANSPORTE 
              AND CUPOS.CUP_NUMERO = INTERFAZ_ENTREGADORES.INE_NUMERO_CUPO(+) 
              AND CUPOS.CUP_SUCURSAL_EMISORA = INTERFAZ_ENTREGADORES.INE_SUCURSAL_EMISORA_CUPO(+) 
              AND CONTRATOS.CNT_TIPO_CONTRATO = 'V' 
              AND CUPOS.CUP_ESTADO IN ('A', 'D', 'U', 'S') 
              AND CONTRATOS.CNT_TIPO_NEGOCIO = TIPOS_NEGOCIO.TNE_CODIGO 
              AND TO_DATE ('01/01/2022', 'DD/MM/YYYY') <= CUPOS.CUP_FECHA_ENTREGA 
              AND TO_DATE ('01/04/2022', 'DD/MM/YYYY') >= CUPOS.CUP_FECHA_ENTREGA
          ) DETALLE_CUPOS 
        GROUP BY 
          TIPO_CONTRATO, 
          NUMERO_CONTRATO
      ) VISTA_CUPOS 
    WHERE 
      CONTRATOS.CNT_TIPO_CONTRATO = 'V' 
      AND CARTAS_DE_PORTE.CPE_TIPO_MOVIMIENTO (+) = APLICACIONES.APC_TIPO_CONTRATO 
      AND CARTAS_DE_PORTE.CPE_SUCURSAL_CARTA_PORTE (+) = APLICACIONES.APC_SUCURSAL_CARTA_PORTE 
      AND CARTAS_DE_PORTE.CPE_NUMERO_CARTA_PORTE (+) = APLICACIONES.APC_NUMERO_CARTA_PORTE 
      AND CARTAS_DE_PORTE.CPE_RENGLON (+) = APLICACIONES.APC_RENGLON 
      AND CONTRATOS.CNT_TIPO_CONTRATO = APLICACIONES.APC_TIPO_CONTRATO (+) 
      AND CONTRATOS.CNT_NUMERO = APLICACIONES.APC_NUMERO_CONTRATO (+) 
      AND CONTRATOS.CNT_NUMERO = VISTA_CUPOS.NUMERO_CONTRATO(+) 
      AND 'V' = VISTA_CUPOS.TIPO_CONTRATO(+) 
      AND CONTRATOS.CNT_TIPO_NEGOCIO = TIPOS_NEGOCIO.TNE_CODIGO 
    GROUP BY 
      CONTRATOS.CNT_TIPO_CONTRATO, 
      CONTRATOS.CNT_NUMERO, 
      NVL(
        VISTA_CUPOS.KILOS_CUPOS_ASIGNADOS, 
        0
      ), 
      NVL(
        VISTA_CUPOS.KILOS_CUPOS_APLICADOS, 
        0
      ), 
      NVL(
        VISTA_CUPOS.KILOS_CUPOS_CUMP_PENDIENTES, 
        0
      ), 
      NVL(
        VISTA_CUPOS.KILOS_CUPOS_SIN_ASIGNAR, 
        0
      )
  ) APLICADO, 
  (
    SELECT 
      COUNT (CUPOS.CUP_NUMERO) USADOS, 
      CUP_NUMERO_CONTRATO 
    FROM 
      CUPOS 
    WHERE 
      CUP_ESTADO NOT IN ('C', 'V', 'U') 
    GROUP BY 
      CUP_NUMERO_CONTRATO
  ) CUPOS_RESTANTES, 
  (
    SELECT 
      COUNT (CUPOS.CUP_NUMERO) NO_USADOS, 
      CUP_NUMERO_CONTRATO 
    FROM 
      CUPOS 
    WHERE 
      CUP_ESTADO IN ('C', 'V') 
    GROUP BY 
      CUP_NUMERO_CONTRATO
  ) CUPOS_CANCELADOS_VENCIDOS, 
  (
    SELECT 
      TRANSPORTES_ESPECIES.TRANSPORTE, 
      TRANSPORTES_ESPECIES.ESPECIE, 
      NVL(
        CUPOS_PARAMETROS.CPS_TONELADAS, 
        CUPOS_TRANSPORTE.CT_TONELADAS
      ) * 1000 AS KILOS_X_CUPO 
    FROM 
      CUPOS_PARAMETROS, 
      (
        SELECT 
          ESPECIES.ESP_ESPECIE AS ESPECIE, 
          TIPOS_TRANSPORTES.TRANSPORTE 
        FROM 
          ESPECIES, 
          (
            SELECT 
              DISTINCT CUPOS_PARAMETROS.CPS_TIPO_TRANSPORTE AS TRANSPORTE 
            FROM 
              CUPOS_PARAMETROS
          ) TIPOS_TRANSPORTES
      ) TRANSPORTES_ESPECIES, 
      (
        SELECT 
          CUPOS_PARAMETROS.CPS_TIPO_TRANSPORTE AS CT_TRANSPORTE, 
          CUPOS_PARAMETROS.CPS_TONELADAS AS CT_TONELADAS 
        FROM 
          CUPOS_PARAMETROS 
        WHERE 
          CUPOS_PARAMETROS.CPS_ESPECIE IS NULL
      ) CUPOS_TRANSPORTE 
    WHERE 
      TRANSPORTES_ESPECIES.TRANSPORTE = CUPOS_TRANSPORTE.CT_TRANSPORTE (+) 
      AND TRANSPORTES_ESPECIES.TRANSPORTE = CUPOS_PARAMETROS.CPS_TIPO_TRANSPORTE(+) 
      AND TRANSPORTES_ESPECIES.ESPECIE = CUPOS_PARAMETROS.CPS_ESPECIE(+)
  ) TRANS_ESPE, 
  (
    SELECT 
      COUNT (CUPOS.CUP_NUMERO) TOTAL_CUPOS_OTORGADOS, 
      CUP_NUMERO_CONTRATO 
    FROM 
      CUPOS 
    WHERE 
      0 = 0 
    GROUP BY 
      CUP_NUMERO_CONTRATO
  ) OTORGADOS, 
  ENTIDADES ENTIDAD_ENTREGADOR, 
  PROCEDENCIAS_DESTINOS PROCEDENCIA_CNT, 
  PEDIDOS_FLETE_CAMIONES, 
  EGRESOS_PLANTAS, 
  CAMPOS, 
  CONTRATOS CONTRATO_COMPRA_EGRESO, 
  ENTIDADES CORREDOR_CONTRATO_COMPRA, 
  ENTIDADES VENDEDOR_CONTRATO_COMPRA, 
  PEDIDOS_FLETE 
WHERE 
  ENTIDADES.ENT_TIPO_ENTIDAD = 3 
  AND CONTRATOS.CNT_COMPRADOR = ENTIDADES.ENT_CODIGO 
  AND ENTIDAD_PRODUCTOR.ENT_TIPO_ENTIDAD(+) = 3 
  AND ENTIDAD_PRODUCTOR.ENT_CODIGO (+)= CUPOS.CUP_PRODUCTOR 
  AND CONTRATOS.CNT_NUMERO = CUPOS.CUP_NUMERO_CONTRATO 
  AND PROCEDENCIAS_DESTINOS.PDE_CODIGO (+)= CUPOS.CUP_DESTINO 
  AND PROCEDENCIAS_DESTINOS_CNT.PDE_CODIGO = CONTRATOS.CNT_DESTINO 
  AND PLANTAS.PLA_PLANTA (+) = CUPOS.CUP_PLANTA_ORIGEN 
  AND CUPOS_RESTANTES.CUP_NUMERO_CONTRATO (+) = CONTRATOS.CNT_NUMERO 
  AND CUPOS_CANCELADOS_VENCIDOS.CUP_NUMERO_CONTRATO (+) = CONTRATOS.CNT_NUMERO 
  AND OTORGADOS.CUP_NUMERO_CONTRATO (+) = CONTRATOS.CNT_NUMERO 
  AND CONTRATOS.CNT_TIPO_CONTRATO = 'C' 
  AND 3 = CORREDORES.ENT_TIPO_ENTIDAD 
  AND CONTRATOS.CNT_CORREDOR = CORREDORES.ENT_CODIGO 
  AND CONTRATOS.CNT_TIPO_TRANSPORTE = TRANS_ESPE.TRANSPORTE 
  AND CONTRATOS.CNT_ESPECIE = TRANS_ESPE.ESPECIE 
  AND CONTRATOS.CNT_NUMERO = APLICADO.CNT_NUMERO(+) 
  AND CUPOS.CUP_TIPO_CONTRATO_COMPRA = CONTRATOS_COMPRA.CNT_TIPO_CONTRATO (+) 
  AND CUPOS.CUP_CONTRATO_COMPRA = CONTRATOS_COMPRA.CNT_NUMERO (+) 
  AND VENDEDOR_CONTRATOS_COMPRA.ENT_TIPO_ENTIDAD(+) = 3 
  AND VENDEDOR_CONTRATOS_COMPRA.ENT_CODIGO(+) = CONTRATOS_COMPRA.CNT_VENDEDOR 
  AND ENTIDAD_ENTREGADOR.ENT_TIPO_ENTIDAD (+) = 3 
  AND CONTRATOS.CNT_ENTREGADOR = ENTIDAD_ENTREGADOR.ENT_CODIGO (+) 
  AND PROCEDENCIA_CNT.PDE_CODIGO = CONTRATOS.CNT_PROCEDENCIA(+) 
  AND CONTRATOS.CNT_TIPO_CONTRATO = CUPOS.CUP_TIPO_CONTRATO (+) 
  AND CONTRATOS.CNT_NUMERO = CUPOS.CUP_NUMERO_CONTRATO (+) 
  AND CUPOS.CUP_SUCURSAL_EMISORA = PEDIDOS_FLETE_CAMIONES.PFC_SUCURSAL_EMISORA_CUPO(+) 
  AND CUPOS.CUP_NUMERO = PEDIDOS_FLETE_CAMIONES.PFC_NUMERO_CUPO(+) 
  AND PEDIDOS_FLETE_CAMIONES.PFC_PUNTO_EGRESO_BALANZA = EGRESOS_PLANTAS.EPL_PUNTO_EGRESO (+) 
  AND PEDIDOS_FLETE_CAMIONES.PFC_NUMERO_EGRESO_BALANZA = EGRESOS_PLANTAS.EPL_NUMERO_EGRESO (+) 
  AND EGRESOS_PLANTAS.EPL_CAMPO = CAMPOS.CAM_CAMPO (+) 
  AND EGRESOS_PLANTAS.EPL_TIPO_CONTRATO_COMPRA = CONTRATO_COMPRA_EGRESO.CNT_TIPO_CONTRATO(+) 
  AND EGRESOS_PLANTAS.EPL_CONTRATO_COMPRA = CONTRATO_COMPRA_EGRESO.CNT_NUMERO(+) 
  AND CONTRATO_COMPRA_EGRESO.CNT_CORREDOR = CORREDOR_CONTRATO_COMPRA.ENT_CODIGO(+) 
  AND CORREDOR_CONTRATO_COMPRA.ENT_TIPO_ENTIDAD(+) = 3 
  AND CONTRATO_COMPRA_EGRESO.CNT_VENDEDOR = VENDEDOR_CONTRATO_COMPRA.ENT_CODIGO(+) 
  AND VENDEDOR_CONTRATO_COMPRA.ENT_TIPO_ENTIDAD(+) = 3 
  AND CONTRATOS.CNT_NUMERO = PEDIDOS_FLETE.PFT_CONTRATO_COMPRA 
  AND CONTRATOS.CNT_TIPO_CONTRATO = PEDIDOS_FLETE.PFT_TIPO_CONTRATO_COMPRA 
  AND PEDIDOS_FLETE.PFT_TIPO_MOVIMIENTO = 'N' 
  AND TO_DATE ('01/01/2022', 'DD/MM/YYYY') <= CUPOS.CUP_FECHA_ENTREGA 
  AND TO_DATE ('01/04/2022', 'DD/MM/YYYY') >= CUPOS.CUP_FECHA_ENTREGA 
UNION ALL 
SELECT 
  NULL, 
  NULL, 
  0 AS PLANTA, 
  NULL, 
  NULL, 
  NULL, 
  NULL, 
  NULL, 
  NULL, 
  CONTRATOS.CNT_NUMERO, 
  CONTRATOS.CNT_COMPRADOR, 
  ENTIDADES.ENT_NOMBRE, 
  CONTRATOS.CNT_ESPECIE, 
  CONTRATOS.CNT_COSECHA, 
  CONTRATOS.CNT_KILOS_PROMEDIO, 
  CONTRATOS.CNT_FECHA_DESDE_ENTREGAS, 
  NULL, 
  NULL, 
  '0000000000', 
  NULL, 
  CEIL (
    (
      CONTRATOS.CNT_KILOS_PROMEDIO + NVL (
        CONTRATOS.CNT_KILOS_EXCEDENTES, 
        0
      ) - NVL(APLICADO.TOTAL_NETO, 0) - NVL(
        APLICADO.TOTAL_ENVIADO_SIN_DESCARGAR, 
        0
      ) - NVL(
        APLICADO.KILOS_CUPOS_CUMP_PENDIENTES, 
        0
      )
    ) / TRANS_ESPE.KILOS_X_CUPO
  ) + NVL(NO_USADOS, 0) AS CANTIDAD_CUPOS, 
  CEIL (
    (
      CONTRATOS.CNT_KILOS_PROMEDIO + NVL (
        CONTRATOS.CNT_KILOS_EXCEDENTES, 
        0
      ) - NVL(APLICADO.TOTAL_NETO, 0) - NVL(
        APLICADO.TOTAL_ENVIADO_SIN_DESCARGAR, 
        0
      ) - NVL(
        APLICADO.KILOS_CUPOS_CUMP_PENDIENTES, 
        0
      )
    ) / TRANS_ESPE.KILOS_X_CUPO
  ) - NVL(USADOS, 0) AS CUPOS_RESTANTES, 
  CONTRATOS.CNT_DESTINO, 
  NULL, 
  NO_USADOS, 
  NULL as COMPROBANTE_COMPRA, 
  NULL AS CUP_NUMERO_EXTERNO, 
  TRIM(CORREDORES.ENT_CODIGO) || ' ' || CORREDORES.ENT_NOMBRE AS CORREDOR, 
  NULL AS PROD_CVC, 
  NULL AS CUP_DESCRIPCION_CANCELACION, 
  OTORGADOS.TOTAL_CUPOS_OTORGADOS, 
  NULL AS VENDEDOR_CTO_COMPRA, 
  TO_CHAR(
    PEDIDOS_FLETE_CAMIONES.PFC_PUNTO_EGRESO_BALANZA, 
    'fm0000'
  ) || '-' || TO_CHAR(
    PEDIDOS_FLETE_CAMIONES.PFC_NUMERO_EGRESO_BALANZA, 
    'fm00000000'
  ) AS NRO_EGRESO, 
  TRIM (ENTIDAD_ENTREGADOR.ENT_CODIGO)|| ' ' || ENTIDAD_ENTREGADOR.ENT_NOMBRE ENTREGADOR, 
  CONTRATOS.CNT_PROCEDENCIA || ' ' || PROCEDENCIA_CNT.PDE_DESCRIPCION AS PROCEDENCIA_CNT, 
  TRIM (
    CAMPOS.CAM_CAMPO || ' ' || CAMPOS.CAM_DESCRIPCION
  ) AS CAMPO, 
  TO_DATE(null, 'DD/MM/YYYY') as FECHA_ASIGNACION, 
  CONTRATO_COMPRA_EGRESO.CNT_NUMERO AS NRO_CTTO_COMPRA, 
  TRIM (
    CORREDOR_CONTRATO_COMPRA.ENT_CODIGO
  ) AS COD_CORREDOR_CTTO_COMPRA, 
  CORREDOR_CONTRATO_COMPRA.ENT_NOMBRE AS CORREDOR_CTTO_COMPRA, 
  TRIM (
    VENDEDOR_CONTRATO_COMPRA.ENT_CODIGO
  ) AS COD_VENDEDOR_CTTO_COMPRA, 
  VENDEDOR_CONTRATO_COMPRA.ENT_NOMBRE AS VENDEDOR_CTTO_COMPRA 
FROM 
  CONTRATOS, 
  ENTIDADES, 
  ENTIDADES CORREDORES, 
  (
    SELECT 
      COUNT (CUPOS.CUP_NUMERO) CUPOS, 
      CUPOS.CUP_TIPO_CONTRATO, 
      CUP_NUMERO_CONTRATO 
    FROM 
      CUPOS 
    WHERE 
      CUP_ESTADO <> 'C' 
      AND CUP_ESTADO <> 'V' 
      AND CUP_ESTADO <> 'U' 
      AND CUP_ESTADO <> 'P' 
    GROUP BY 
      CUPOS.CUP_TIPO_CONTRATO, 
      CUP_NUMERO_CONTRATO
  ) CANTIDAD_CUPOS, 
  (
    SELECT 
      ROWNUM CONTADOR 
    FROM 
      ALL_OBJECTS 
    WHERE 
      ROWNUM <= 100000
  ), 
  (
    SELECT 
      TRANSPORTES_ESPECIES.TRANSPORTE, 
      TRANSPORTES_ESPECIES.ESPECIE, 
      NVL(
        CUPOS_PARAMETROS.CPS_TONELADAS, 
        CUPOS_TRANSPORTE.CT_TONELADAS
      ) * 1000 AS KILOS_X_CUPO 
    FROM 
      CUPOS_PARAMETROS, 
      (
        SELECT 
          ESPECIES.ESP_ESPECIE AS ESPECIE, 
          TIPOS_TRANSPORTES.TRANSPORTE 
        FROM 
          ESPECIES, 
          (
            SELECT 
              DISTINCT CUPOS_PARAMETROS.CPS_TIPO_TRANSPORTE AS TRANSPORTE 
            FROM 
              CUPOS_PARAMETROS
          ) TIPOS_TRANSPORTES
      ) TRANSPORTES_ESPECIES, 
      (
        SELECT 
          CUPOS_PARAMETROS.CPS_TIPO_TRANSPORTE AS CT_TRANSPORTE, 
          CUPOS_PARAMETROS.CPS_TONELADAS AS CT_TONELADAS 
        FROM 
          CUPOS_PARAMETROS 
        WHERE 
          CUPOS_PARAMETROS.CPS_ESPECIE IS NULL
      ) CUPOS_TRANSPORTE 
    WHERE 
      TRANSPORTES_ESPECIES.TRANSPORTE = CUPOS_TRANSPORTE.CT_TRANSPORTE (+) 
      AND TRANSPORTES_ESPECIES.TRANSPORTE = CUPOS_PARAMETROS.CPS_TIPO_TRANSPORTE(+) 
      AND TRANSPORTES_ESPECIES.ESPECIE = CUPOS_PARAMETROS.CPS_ESPECIE(+)
  ) TRANS_ESPE, 
  (
    SELECT 
      CONTRATOS.CNT_TIPO_CONTRATO, 
      CONTRATOS.CNT_NUMERO, 
      NVL (
        SUM (
          CARTAS_DE_PORTE.CPE_KILOS_BRUTOS
        ), 
        0
      ) AS TOTAL_BRUTO, 
      SUM(
        DECODE(
          CPE_KILOS_NETOS, 
          NULL, 
          CPE_KILOS_ENVIADOS, 
          0, 
          CPE_KILOS_ENVIADOS, 
          ROUND(
            (
              (
                APLICACIONES.APC_KILOS_NETOS * CARTAS_DE_PORTE.CPE_KILOS_ENVIADOS
              ) / CARTAS_DE_PORTE.CPE_KILOS_NETOS
            ), 
            0
          )
        )
      ) AS TOTAL_ENVIADO, 
      NVL (
        SUM (
          APLICACIONES.APC_KILOS_DESCARGADOS
        ), 
        0
      ) AS TOTAL_DESCARGADO, 
      NVL (
        SUM (
          APLICACIONES.APC_KILOS_MERMA_HUMEDAD
        ), 
        0
      ) AS TOTAL_HUMEDAD, 
      NVL (
        SUM (
          APLICACIONES.APC_KILOS_MERMA_ZARANDEO
        ), 
        0
      ) AS TOTAL_ZARANDEO, 
      NVL (
        SUM (
          APLICACIONES.APC_KILOS_MERMA_VOLATIL
        ), 
        0
      ) AS TOTAL_VOLATIL, 
      NVL (
        SUM (APLICACIONES.APC_KILOS_NETOS), 
        0
      ) AS TOTAL_NETO, 
      NVL(
        SUM(
          DECODE(
            CPE_KILOS_NETOS, NULL, CPE_KILOS_ENVIADOS, 
            0
          )
        ), 
        0
      ) AS TOTAL_ENVIADO_SIN_DESCARGAR, 
      NVL(
        SUM(
          DECODE(
            NVL(TNE_PRESTAMO, 'No'), 
            'Sí', 
            APLICACIONES.APC_KILOS_NETOS * DECODE(
              SIGN(APLICACIONES.APC_KILOS_NETOS), 
              -1, 
              0, 
              1
            ), 
            0
          )
        ), 
        0
      ) AS TOTAL_NETO_ENTREGADO, 
      NVL(
        SUM(
          DECODE(
            NVL(TNE_PRESTAMO, 'No'), 
            'Sí', 
            APLICACIONES.APC_KILOS_NETOS * DECODE(
              SIGN(APLICACIONES.APC_KILOS_NETOS), 
              -1, 
              1, 
              0
            ) * (-1), 
            0
          )
        ), 
        0
      ) AS TOTAL_NETO_RECIBIDO, 
      NVL(
        VISTA_CUPOS.KILOS_CUPOS_ASIGNADOS, 
        0
      ) AS KILOS_CUPOS_ASIGNADOS, 
      NVL(
        VISTA_CUPOS.KILOS_CUPOS_APLICADOS, 
        0
      ) AS KILOS_CUPOS_APLICADOS, 
      NVL(
        VISTA_CUPOS.KILOS_CUPOS_CUMP_PENDIENTES, 
        0
      ) AS KILOS_CUPOS_CUMP_PENDIENTES, 
      NVL(
        VISTA_CUPOS.KILOS_CUPOS_SIN_ASIGNAR, 
        0
      ) AS KILOS_CUPOS_SIN_ASIGNAR 
    FROM 
      CONTRATOS, 
      APLICACIONES, 
      CARTAS_DE_PORTE, 
      TIPOS_NEGOCIO, 
      (
        SELECT 
          DETALLE_CUPOS.TIPO_CONTRATO, 
          DETALLE_CUPOS.NUMERO_CONTRATO, 
          NULL AS KILOS_X_CUPO, 
          COUNT(DETALLE_CUPOS.CUP_NUMERO) AS CANTIDAD_CUPOS, 
          ROUND (
            SUM(
              NVL(DETALLE_CUPOS.KILOS_X_CUPO, 0) * DECODE (
                DETALLE_CUPOS.CUP_ESTADO, 'A', 1, 
                'D', 1, 0
              )
            ), 
            0
          ) AS TOT_KILOS_CUPOS_APLI, 
          SUM(
            DECODE(
              DETALLE_CUPOS.CUP_ESTADO, 'A', 1, 
              0
            )
          ) AS CANTIDAD_CUPOS_ASIGNADOS, 
          SUM(
            DECODE(
              DETALLE_CUPOS.CUP_ESTADO, 'D', 1, 
              0
            )
          ) AS CANTIDAD_CUPOS_APLICADOS, 
          ROUND (
            SUM(
              NVL (DETALLE_CUPOS.KILOS_X_CUPO, 0) * DECODE(
                DETALLE_CUPOS.CUP_ESTADO, 'A', 1, 
                0
              )
            ), 
            0
          ) AS KILOS_CUPOS_ASIGNADOS, 
          ROUND (
            SUM(
              NVL (DETALLE_CUPOS.KILOS_X_CUPO, 0) * DECODE(
                DETALLE_CUPOS.CUP_ESTADO, 'D', 1, 
                0
              )
            ), 
            0
          ) AS KILOS_CUPOS_APLICADOS, 
          SUM(
            DECODE (
              DETALLE_CUPOS.CUP_ESTADO, 'U', 1, 
              0
            )
          ) AS CANTIDAD_CUPOS_CUMP_PENDIENTES, 
          ROUND(
            SUM(
              NVL(
                DETALLE_CUPOS.INE_KILOS_NETOS, 0
              ) * DECODE (
                DETALLE_CUPOS.CUP_ESTADO, 'U', 1, 
                0
              )
            ), 
            0
          ) AS KILOS_CUPOS_CUMP_PENDIENTES, 
          ROUND(
            SUM(
              NVL(DETALLE_CUPOS.KILOS_X_CUPO, 0) * DECODE (
                DETALLE_CUPOS.CUP_ESTADO, 'S', 1, 
                0
              )
            ), 
            0
          ) AS KILOS_CUPOS_SIN_ASIGNAR, 
          SUM (
            DECODE (
              DETALLE_CUPOS.CUP_ESTADO, 'S', 1, 
              0
            )
          ) AS CANTIDAD_CUPOS_SIN_ASIGNAR 
        FROM 
          (
            SELECT 
              CONTRATOS.CNT_TIPO_CONTRATO AS TIPO_CONTRATO, 
              CONTRATOS.CNT_NUMERO AS NUMERO_CONTRATO, 
              NVL(
                KILOS_TRANSPORTE.KILOS_X_CUPO, 0
              ) AS KILOS_X_CUPO, 
              CUPOS.CUP_NUMERO, 
              CUPOS.CUP_ESTADO, 
              INTERFAZ_ENTREGADORES.INE_KILOS_NETOS 
            FROM 
              CONTRATOS, 
              CUPOS, 
              INTERFAZ_ENTREGADORES, 
              TIPOS_NEGOCIO, 
              (
                SELECT 
                  TRANSPORTES_ESPECIES.TRANSPORTE, 
                  TRANSPORTES_ESPECIES.ESPECIE, 
                  NVL(
                    CUPOS_PARAMETROS.CPS_TONELADAS, 
                    CUPOS_TRANSPORTE.CT_TONELADAS
                  ) * 1000 AS KILOS_X_CUPO 
                FROM 
                  CUPOS_PARAMETROS, 
                  (
                    SELECT 
                      ESPECIES.ESP_ESPECIE AS ESPECIE, 
                      TIPOS_TRANSPORTES.TRANSPORTE 
                    FROM 
                      ESPECIES, 
                      (
                        SELECT 
                          DISTINCT CUPOS_PARAMETROS.CPS_TIPO_TRANSPORTE AS TRANSPORTE 
                        FROM 
                          CUPOS_PARAMETROS
                      ) TIPOS_TRANSPORTES
                  ) TRANSPORTES_ESPECIES, 
                  (
                    SELECT 
                      CUPOS_PARAMETROS.CPS_TIPO_TRANSPORTE AS CT_TRANSPORTE, 
                      CUPOS_PARAMETROS.CPS_TONELADAS AS CT_TONELADAS 
                    FROM 
                      CUPOS_PARAMETROS 
                    WHERE 
                      CUPOS_PARAMETROS.CPS_ESPECIE IS NULL
                  ) CUPOS_TRANSPORTE 
                WHERE 
                  TRANSPORTES_ESPECIES.TRANSPORTE = CUPOS_TRANSPORTE.CT_TRANSPORTE (+) 
                  AND TRANSPORTES_ESPECIES.TRANSPORTE = CUPOS_PARAMETROS.CPS_TIPO_TRANSPORTE(+) 
                  AND TRANSPORTES_ESPECIES.ESPECIE = CUPOS_PARAMETROS.CPS_ESPECIE(+)
              ) KILOS_TRANSPORTE 
            WHERE 
              CUPOS.CUP_TIPO_CONTRATO = CONTRATOS.CNT_TIPO_CONTRATO 
              AND CUPOS.CUP_NUMERO_CONTRATO = CONTRATOS.CNT_NUMERO 
              AND NVL(CUPOS.CUP_TIPO_CUPO, 'C') = 'C' 
              AND CONTRATOS.CNT_ESPECIE = KILOS_TRANSPORTE.ESPECIE(+) 
              AND DECODE(
                CONTRATOS.CNT_TIPO_TRANSPORTE, 
                'Ambos', 
                NVL(
                  CUPOS.CUP_TIPO_TRANSPORTE, 'Camión'
                ), 
                CONTRATOS.CNT_TIPO_TRANSPORTE
              ) = KILOS_TRANSPORTE.TRANSPORTE 
              AND CUPOS.CUP_NUMERO = INTERFAZ_ENTREGADORES.INE_NUMERO_CUPO(+) 
              AND CUPOS.CUP_SUCURSAL_EMISORA = INTERFAZ_ENTREGADORES.INE_SUCURSAL_EMISORA_CUPO(+) 
              AND CONTRATOS.CNT_TIPO_CONTRATO = 'V' 
              AND CUPOS.CUP_ESTADO IN ('A', 'D', 'U', 'S') 
              AND CONTRATOS.CNT_TIPO_NEGOCIO = TIPOS_NEGOCIO.TNE_CODIGO 
              AND TO_DATE ('01/01/2022', 'DD/MM/YYYY') <= CUPOS.CUP_FECHA_ENTREGA 
              AND TO_DATE ('01/04/2022', 'DD/MM/YYYY') >= CUPOS.CUP_FECHA_ENTREGA
          ) DETALLE_CUPOS 
        GROUP BY 
          TIPO_CONTRATO, 
          NUMERO_CONTRATO
      ) VISTA_CUPOS 
    WHERE 
      CONTRATOS.CNT_TIPO_CONTRATO = 'V' 
      AND CARTAS_DE_PORTE.CPE_TIPO_MOVIMIENTO (+) = APLICACIONES.APC_TIPO_CONTRATO 
      AND CARTAS_DE_PORTE.CPE_SUCURSAL_CARTA_PORTE (+) = APLICACIONES.APC_SUCURSAL_CARTA_PORTE 
      AND CARTAS_DE_PORTE.CPE_NUMERO_CARTA_PORTE (+) = APLICACIONES.APC_NUMERO_CARTA_PORTE 
      AND CARTAS_DE_PORTE.CPE_RENGLON (+) = APLICACIONES.APC_RENGLON 
      AND CONTRATOS.CNT_TIPO_CONTRATO = APLICACIONES.APC_TIPO_CONTRATO (+) 
      AND CONTRATOS.CNT_NUMERO = APLICACIONES.APC_NUMERO_CONTRATO (+) 
      AND CONTRATOS.CNT_NUMERO = VISTA_CUPOS.NUMERO_CONTRATO(+) 
      AND 'V' = VISTA_CUPOS.TIPO_CONTRATO(+) 
      AND CONTRATOS.CNT_TIPO_NEGOCIO = TIPOS_NEGOCIO.TNE_CODIGO 
    GROUP BY 
      CONTRATOS.CNT_TIPO_CONTRATO, 
      CONTRATOS.CNT_NUMERO, 
      NVL(
        VISTA_CUPOS.KILOS_CUPOS_ASIGNADOS, 
        0
      ), 
      NVL(
        VISTA_CUPOS.KILOS_CUPOS_APLICADOS, 
        0
      ), 
      NVL(
        VISTA_CUPOS.KILOS_CUPOS_CUMP_PENDIENTES, 
        0
      ), 
      NVL(
        VISTA_CUPOS.KILOS_CUPOS_SIN_ASIGNAR, 
        0
      )
  ) APLICADO, 
  (
    SELECT 
      COUNT (CUPOS.CUP_NUMERO) USADOS, 
      CUPOS.CUP_TIPO_CONTRATO, 
      CUP_NUMERO_CONTRATO 
    FROM 
      CUPOS 
    WHERE 
      CUP_ESTADO NOT IN ('C', 'V', 'U', 'P') 
    GROUP BY 
      CUPOS.CUP_TIPO_CONTRATO, 
      CUP_NUMERO_CONTRATO
  ) CUPOS_RESTANTES, 
  (
    SELECT 
      COUNT (CUPOS.CUP_NUMERO) NO_USADOS, 
      CUPOS.CUP_TIPO_CONTRATO, 
      CUP_NUMERO_CONTRATO 
    FROM 
      CUPOS 
    WHERE 
      CUP_ESTADO IN ('C', 'V') 
    GROUP BY 
      CUPOS.CUP_TIPO_CONTRATO, 
      CUP_NUMERO_CONTRATO
  ) CUPOS_CANCELADOS_VENCIDOS, 
  (
    SELECT 
      COUNT (CONTRATOS.CNT_NUMERO) CUPOS, 
      CONTRATOS.CNT_TIPO_CONTRATO, 
      CONTRATOS.CNT_NUMERO 
    FROM 
      CONTRATOS, 
      (
        SELECT 
          COUNT (CUPOS.CUP_NUMERO) CUPOS, 
          CUP_NUMERO_CONTRATO 
        FROM 
          CUPOS 
        WHERE 
          CUP_ESTADO <> 'C' 
          AND CUP_ESTADO <> 'V' 
        GROUP BY 
          CUP_NUMERO_CONTRATO
      ) CANTIDAD_CUPOS, 
      (
        SELECT 
          TRANSPORTES_ESPECIES.TRANSPORTE, 
          TRANSPORTES_ESPECIES.ESPECIE, 
          NVL(
            CUPOS_PARAMETROS.CPS_TONELADAS, 
            CUPOS_TRANSPORTE.CT_TONELADAS
          ) * 1000 AS KILOS_X_CUPO 
        FROM 
          CUPOS_PARAMETROS, 
          (
            SELECT 
              ESPECIES.ESP_ESPECIE AS ESPECIE, 
              TIPOS_TRANSPORTES.TRANSPORTE 
            FROM 
              ESPECIES, 
              (
                SELECT 
                  DISTINCT CUPOS_PARAMETROS.CPS_TIPO_TRANSPORTE AS TRANSPORTE 
                FROM 
                  CUPOS_PARAMETROS
              ) TIPOS_TRANSPORTES
          ) TRANSPORTES_ESPECIES, 
          (
            SELECT 
              CUPOS_PARAMETROS.CPS_TIPO_TRANSPORTE AS CT_TRANSPORTE, 
              CUPOS_PARAMETROS.CPS_TONELADAS AS CT_TONELADAS 
            FROM 
              CUPOS_PARAMETROS 
            WHERE 
              CUPOS_PARAMETROS.CPS_ESPECIE IS NULL
          ) CUPOS_TRANSPORTE 
        WHERE 
          TRANSPORTES_ESPECIES.TRANSPORTE = CUPOS_TRANSPORTE.CT_TRANSPORTE (+) 
          AND TRANSPORTES_ESPECIES.TRANSPORTE = CUPOS_PARAMETROS.CPS_TIPO_TRANSPORTE(+) 
          AND TRANSPORTES_ESPECIES.ESPECIE = CUPOS_PARAMETROS.CPS_ESPECIE(+)
      ) TRANS_ESPE, 
      (
        SELECT 
          CONTRATOS.CNT_TIPO_CONTRATO, 
          CONTRATOS.CNT_NUMERO, 
          NVL (
            SUM (
              CARTAS_DE_PORTE.CPE_KILOS_BRUTOS
            ), 
            0
          ) AS TOTAL_BRUTO, 
          SUM(
            DECODE(
              CPE_KILOS_NETOS, 
              NULL, 
              CPE_KILOS_ENVIADOS, 
              0, 
              CPE_KILOS_ENVIADOS, 
              ROUND(
                (
                  (
                    APLICACIONES.APC_KILOS_NETOS * CARTAS_DE_PORTE.CPE_KILOS_ENVIADOS
                  ) / CARTAS_DE_PORTE.CPE_KILOS_NETOS
                ), 
                0
              )
            )
          ) AS TOTAL_ENVIADO, 
          NVL (
            SUM (
              APLICACIONES.APC_KILOS_DESCARGADOS
            ), 
            0
          ) AS TOTAL_DESCARGADO, 
          NVL (
            SUM (
              APLICACIONES.APC_KILOS_MERMA_HUMEDAD
            ), 
            0
          ) AS TOTAL_HUMEDAD, 
          NVL (
            SUM (
              APLICACIONES.APC_KILOS_MERMA_ZARANDEO
            ), 
            0
          ) AS TOTAL_ZARANDEO, 
          NVL (
            SUM (
              APLICACIONES.APC_KILOS_MERMA_VOLATIL
            ), 
            0
          ) AS TOTAL_VOLATIL, 
          NVL (
            SUM (APLICACIONES.APC_KILOS_NETOS), 
            0
          ) AS TOTAL_NETO, 
          NVL(
            SUM(
              DECODE(
                CPE_KILOS_NETOS, NULL, CPE_KILOS_ENVIADOS, 
                0
              )
            ), 
            0
          ) AS TOTAL_ENVIADO_SIN_DESCARGAR, 
          NVL(
            SUM(
              DECODE(
                NVL(TNE_PRESTAMO, 'No'), 
                'Sí', 
                APLICACIONES.APC_KILOS_NETOS * DECODE(
                  SIGN(APLICACIONES.APC_KILOS_NETOS), 
                  -1, 
                  0, 
                  1
                ), 
                0
              )
            ), 
            0
          ) AS TOTAL_NETO_ENTREGADO, 
          NVL(
            SUM(
              DECODE(
                NVL(TNE_PRESTAMO, 'No'), 
                'Sí', 
                APLICACIONES.APC_KILOS_NETOS * DECODE(
                  SIGN(APLICACIONES.APC_KILOS_NETOS), 
                  -1, 
                  1, 
                  0
                ) * (-1), 
                0
              )
            ), 
            0
          ) AS TOTAL_NETO_RECIBIDO, 
          NVL(
            VISTA_CUPOS.KILOS_CUPOS_ASIGNADOS, 
            0
          ) AS KILOS_CUPOS_ASIGNADOS, 
          NVL(
            VISTA_CUPOS.KILOS_CUPOS_APLICADOS, 
            0
          ) AS KILOS_CUPOS_APLICADOS, 
          NVL(
            VISTA_CUPOS.KILOS_CUPOS_CUMP_PENDIENTES, 
            0
          ) AS KILOS_CUPOS_CUMP_PENDIENTES, 
          NVL(
            VISTA_CUPOS.KILOS_CUPOS_SIN_ASIGNAR, 
            0
          ) AS KILOS_CUPOS_SIN_ASIGNAR 
        FROM 
          CONTRATOS, 
          APLICACIONES, 
          CARTAS_DE_PORTE, 
          TIPOS_NEGOCIO, 
          (
            SELECT 
              DETALLE_CUPOS.TIPO_CONTRATO, 
              DETALLE_CUPOS.NUMERO_CONTRATO, 
              NULL AS KILOS_X_CUPO, 
              COUNT(DETALLE_CUPOS.CUP_NUMERO) AS CANTIDAD_CUPOS, 
              ROUND (
                SUM(
                  NVL(DETALLE_CUPOS.KILOS_X_CUPO, 0) * DECODE (
                    DETALLE_CUPOS.CUP_ESTADO, 'A', 1, 
                    'D', 1, 0
                  )
                ), 
                0
              ) AS TOT_KILOS_CUPOS_APLI, 
              SUM(
                DECODE(
                  DETALLE_CUPOS.CUP_ESTADO, 'A', 1, 
                  0
                )
              ) AS CANTIDAD_CUPOS_ASIGNADOS, 
              SUM(
                DECODE(
                  DETALLE_CUPOS.CUP_ESTADO, 'D', 1, 
                  0
                )
              ) AS CANTIDAD_CUPOS_APLICADOS, 
              ROUND (
                SUM(
                  NVL (DETALLE_CUPOS.KILOS_X_CUPO, 0) * DECODE(
                    DETALLE_CUPOS.CUP_ESTADO, 'A', 1, 
                    0
                  )
                ), 
                0
              ) AS KILOS_CUPOS_ASIGNADOS, 
              ROUND (
                SUM(
                  NVL (DETALLE_CUPOS.KILOS_X_CUPO, 0) * DECODE(
                    DETALLE_CUPOS.CUP_ESTADO, 'D', 1, 
                    0
                  )
                ), 
                0
              ) AS KILOS_CUPOS_APLICADOS, 
              SUM(
                DECODE (
                  DETALLE_CUPOS.CUP_ESTADO, 'U', 1, 
                  0
                )
              ) AS CANTIDAD_CUPOS_CUMP_PENDIENTES, 
              ROUND(
                SUM(
                  NVL(
                    DETALLE_CUPOS.INE_KILOS_NETOS, 0
                  ) * DECODE (
                    DETALLE_CUPOS.CUP_ESTADO, 'U', 1, 
                    0
                  )
                ), 
                0
              ) AS KILOS_CUPOS_CUMP_PENDIENTES, 
              ROUND(
                SUM(
                  NVL(DETALLE_CUPOS.KILOS_X_CUPO, 0) * DECODE (
                    DETALLE_CUPOS.CUP_ESTADO, 'S', 1, 
                    0
                  )
                ), 
                0
              ) AS KILOS_CUPOS_SIN_ASIGNAR, 
              SUM (
                DECODE (
                  DETALLE_CUPOS.CUP_ESTADO, 'S', 1, 
                  0
                )
              ) AS CANTIDAD_CUPOS_SIN_ASIGNAR 
            FROM 
              (
                SELECT 
                  CONTRATOS.CNT_TIPO_CONTRATO AS TIPO_CONTRATO, 
                  CONTRATOS.CNT_NUMERO AS NUMERO_CONTRATO, 
                  NVL(
                    KILOS_TRANSPORTE.KILOS_X_CUPO, 0
                  ) AS KILOS_X_CUPO, 
                  CUPOS.CUP_NUMERO, 
                  CUPOS.CUP_ESTADO, 
                  INTERFAZ_ENTREGADORES.INE_KILOS_NETOS 
                FROM 
                  CONTRATOS, 
                  CUPOS, 
                  INTERFAZ_ENTREGADORES, 
                  TIPOS_NEGOCIO, 
                  (
                    SELECT 
                      TRANSPORTES_ESPECIES.TRANSPORTE, 
                      TRANSPORTES_ESPECIES.ESPECIE, 
                      NVL(
                        CUPOS_PARAMETROS.CPS_TONELADAS, 
                        CUPOS_TRANSPORTE.CT_TONELADAS
                      ) * 1000 AS KILOS_X_CUPO 
                    FROM 
                      CUPOS_PARAMETROS, 
                      (
                        SELECT 
                          ESPECIES.ESP_ESPECIE AS ESPECIE, 
                          TIPOS_TRANSPORTES.TRANSPORTE 
                        FROM 
                          ESPECIES, 
                          (
                            SELECT 
                              DISTINCT CUPOS_PARAMETROS.CPS_TIPO_TRANSPORTE AS TRANSPORTE 
                            FROM 
                              CUPOS_PARAMETROS
                          ) TIPOS_TRANSPORTES
                      ) TRANSPORTES_ESPECIES, 
                      (
                        SELECT 
                          CUPOS_PARAMETROS.CPS_TIPO_TRANSPORTE AS CT_TRANSPORTE, 
                          CUPOS_PARAMETROS.CPS_TONELADAS AS CT_TONELADAS 
                        FROM 
                          CUPOS_PARAMETROS 
                        WHERE 
                          CUPOS_PARAMETROS.CPS_ESPECIE IS NULL
                      ) CUPOS_TRANSPORTE 
                    WHERE 
                      TRANSPORTES_ESPECIES.TRANSPORTE = CUPOS_TRANSPORTE.CT_TRANSPORTE (+) 
                      AND TRANSPORTES_ESPECIES.TRANSPORTE = CUPOS_PARAMETROS.CPS_TIPO_TRANSPORTE(+) 
                      AND TRANSPORTES_ESPECIES.ESPECIE = CUPOS_PARAMETROS.CPS_ESPECIE(+)
                  ) KILOS_TRANSPORTE 
                WHERE 
                  CUPOS.CUP_TIPO_CONTRATO = CONTRATOS.CNT_TIPO_CONTRATO 
                  AND CUPOS.CUP_NUMERO_CONTRATO = CONTRATOS.CNT_NUMERO 
                  AND NVL(CUPOS.CUP_TIPO_CUPO, 'C') = 'C' 
                  AND CONTRATOS.CNT_ESPECIE = KILOS_TRANSPORTE.ESPECIE(+) 
                  AND DECODE(
                    CONTRATOS.CNT_TIPO_TRANSPORTE, 
                    'Ambos', 
                    NVL(
                      CUPOS.CUP_TIPO_TRANSPORTE, 'Camión'
                    ), 
                    CONTRATOS.CNT_TIPO_TRANSPORTE
                  ) = KILOS_TRANSPORTE.TRANSPORTE 
                  AND CUPOS.CUP_NUMERO = INTERFAZ_ENTREGADORES.INE_NUMERO_CUPO(+) 
                  AND CUPOS.CUP_SUCURSAL_EMISORA = INTERFAZ_ENTREGADORES.INE_SUCURSAL_EMISORA_CUPO(+) 
                  AND CONTRATOS.CNT_TIPO_CONTRATO = 'V' 
                  AND CUPOS.CUP_ESTADO IN ('A', 'D', 'U', 'S') 
                  AND CONTRATOS.CNT_TIPO_NEGOCIO = TIPOS_NEGOCIO.TNE_CODIGO 
                  AND TO_DATE ('01/01/2022', 'DD/MM/YYYY') <= CUPOS.CUP_FECHA_ENTREGA 
                  AND TO_DATE ('01/04/2022', 'DD/MM/YYYY') >= CUPOS.CUP_FECHA_ENTREGA
              ) DETALLE_CUPOS 
            GROUP BY 
              TIPO_CONTRATO, 
              NUMERO_CONTRATO
          ) VISTA_CUPOS 
        WHERE 
          CONTRATOS.CNT_TIPO_CONTRATO = 'V' 
          AND CARTAS_DE_PORTE.CPE_TIPO_MOVIMIENTO (+) = APLICACIONES.APC_TIPO_CONTRATO 
          AND CARTAS_DE_PORTE.CPE_SUCURSAL_CARTA_PORTE (+) = APLICACIONES.APC_SUCURSAL_CARTA_PORTE 
          AND CARTAS_DE_PORTE.CPE_NUMERO_CARTA_PORTE (+) = APLICACIONES.APC_NUMERO_CARTA_PORTE 
          AND CARTAS_DE_PORTE.CPE_RENGLON (+) = APLICACIONES.APC_RENGLON 
          AND CONTRATOS.CNT_TIPO_CONTRATO = APLICACIONES.APC_TIPO_CONTRATO (+) 
          AND CONTRATOS.CNT_NUMERO = APLICACIONES.APC_NUMERO_CONTRATO (+) 
          AND CONTRATOS.CNT_NUMERO = VISTA_CUPOS.NUMERO_CONTRATO(+) 
          AND 'V' = VISTA_CUPOS.TIPO_CONTRATO(+) 
          AND CONTRATOS.CNT_TIPO_NEGOCIO = TIPOS_NEGOCIO.TNE_CODIGO 
        GROUP BY 
          CONTRATOS.CNT_TIPO_CONTRATO, 
          CONTRATOS.CNT_NUMERO, 
          NVL(
            VISTA_CUPOS.KILOS_CUPOS_ASIGNADOS, 
            0
          ), 
          NVL(
            VISTA_CUPOS.KILOS_CUPOS_APLICADOS, 
            0
          ), 
          NVL(
            VISTA_CUPOS.KILOS_CUPOS_CUMP_PENDIENTES, 
            0
          ), 
          NVL(
            VISTA_CUPOS.KILOS_CUPOS_SIN_ASIGNAR, 
            0
          )
      ) APLICADO, 
      (
        SELECT 
          ROWNUM CONTADOR 
        FROM 
          ALL_OBJECTS 
        WHERE 
          ROWNUM <= 100000
      ) 
    WHERE 
      CONTRATOS.CNT_TIPO_CONTRATO = 'C' 
      AND CONTRATOS.CNT_TIPO_TRANSPORTE = TRANS_ESPE.TRANSPORTE 
      AND CONTRATOS.CNT_ESPECIE = TRANS_ESPE.ESPECIE 
      AND CONTRATOS.CNT_NUMERO = APLICADO.CNT_NUMERO(+) 
      AND CONTADOR <= (
        CEIL (
          (
            CONTRATOS.CNT_KILOS_PROMEDIO + NVL (
              CONTRATOS.CNT_KILOS_EXCEDENTES, 
              0
            ) - NVL(APLICADO.TOTAL_NETO, 0) - NVL(
              APLICADO.TOTAL_ENVIADO_SIN_DESCARGAR, 
              0
            ) - NVL(
              APLICADO.KILOS_CUPOS_CUMP_PENDIENTES, 
              0
            )
          ) / TRANS_ESPE.KILOS_X_CUPO
        )
      ) 
      AND CONTRATOS.CNT_NUMERO = CANTIDAD_CUPOS.CUP_NUMERO_CONTRATO (+) 
    GROUP BY 
      CONTRATOS.CNT_TIPO_CONTRATO, 
      CONTRATOS.CNT_NUMERO
  ) TOTAL, 
  (
    SELECT 
      COUNT (CUPOS.CUP_NUMERO) TOTAL_CUPOS_OTORGADOS, 
      CUP_TIPO_CONTRATO, 
      CUP_NUMERO_CONTRATO, 
      CUP_SUCURSAL_EMISORA, 
      CUP_NUMERO 
    FROM 
      CUPOS 
    WHERE 
      0 = 0 
    GROUP BY 
      CUP_TIPO_CONTRATO, 
      CUP_NUMERO_CONTRATO, 
      CUP_SUCURSAL_EMISORA, 
      CUP_NUMERO
  ) OTORGADOS, 
  ENTIDADES ENTIDAD_ENTREGADOR, 
  PROCEDENCIAS_DESTINOS PROCEDENCIA_CNT, 
  PEDIDOS_FLETE_CAMIONES, 
  EGRESOS_PLANTAS, 
  CAMPOS, 
  CONTRATOS CONTRATO_COMPRA_EGRESO, 
  ENTIDADES CORREDOR_CONTRATO_COMPRA, 
  ENTIDADES VENDEDOR_CONTRATO_COMPRA 
WHERE 
  ENTIDADES.ENT_TIPO_ENTIDAD = 3 
  AND CONTRATOS.CNT_COMPRADOR = ENTIDADES.ENT_CODIGO 
  AND CONTRATOS.CNT_TIPO_CONTRATO = 'C' 
  AND CONTRATOS.CNT_CONFIRMADO = 'Sí' 
  AND CUPOS_RESTANTES.CUP_TIPO_CONTRATO(+) = CONTRATOS.CNT_TIPO_CONTRATO 
  AND CUPOS_RESTANTES.CUP_NUMERO_CONTRATO (+) = CONTRATOS.CNT_NUMERO 
  AND CUPOS_CANCELADOS_VENCIDOS.CUP_TIPO_CONTRATO(+) = CONTRATOS.CNT_TIPO_CONTRATO 
  AND CUPOS_CANCELADOS_VENCIDOS.CUP_NUMERO_CONTRATO (+) = CONTRATOS.CNT_NUMERO 
  AND CANTIDAD_CUPOS.CUP_TIPO_CONTRATO(+) = CONTRATOS.CNT_TIPO_CONTRATO 
  AND CANTIDAD_CUPOS.CUP_NUMERO_CONTRATO (+)= CONTRATOS.CNT_NUMERO 
  AND OTORGADOS.CUP_TIPO_CONTRATO(+) = CONTRATOS.CNT_TIPO_CONTRATO 
  AND OTORGADOS.CUP_NUMERO_CONTRATO (+) = CONTRATOS.CNT_NUMERO 
  AND 3 = CORREDORES.ENT_TIPO_ENTIDAD 
  AND CONTRATOS.CNT_CORREDOR = CORREDORES.ENT_CODIGO 
  AND CONTADOR <= (
    CEIL (
      (
        CONTRATOS.CNT_KILOS_PROMEDIO + NVL (
          CONTRATOS.CNT_KILOS_EXCEDENTES, 
          0
        ) - NVL(APLICADO.TOTAL_NETO, 0) - NVL(
          APLICADO.TOTAL_ENVIADO_SIN_DESCARGAR, 
          0
        ) - NVL(
          APLICADO.KILOS_CUPOS_CUMP_PENDIENTES, 
          0
        )
      ) / TRANS_ESPE.KILOS_X_CUPO
    ) - NVL (CANTIDAD_CUPOS.CUPOS, 0)
  ) 
  AND CONTADOR <= TOTAL.CUPOS 
  AND TOTAL.CNT_TIPO_CONTRATO = CONTRATOS.CNT_TIPO_CONTRATO 
  AND TOTAL.CNT_NUMERO = CONTRATOS.CNT_NUMERO 
  AND CONTRATOS.CNT_TIPO_TRANSPORTE = TRANS_ESPE.TRANSPORTE 
  AND CONTRATOS.CNT_ESPECIE = TRANS_ESPE.ESPECIE 
  AND CONTRATOS.CNT_TIPO_CONTRATO = APLICADO.CNT_TIPO_CONTRATO(+) 
  AND CONTRATOS.CNT_NUMERO = APLICADO.CNT_NUMERO(+) 
  AND ENTIDAD_ENTREGADOR.ENT_TIPO_ENTIDAD (+) = 3 
  AND CONTRATOS.CNT_ENTREGADOR = ENTIDAD_ENTREGADOR.ENT_CODIGO (+) 
  AND PROCEDENCIA_CNT.PDE_CODIGO = CONTRATOS.CNT_PROCEDENCIA(+) 
  AND CONTRATOS.CNT_TIPO_CONTRATO = OTORGADOS.CUP_TIPO_CONTRATO (+) 
  AND CONTRATOS.CNT_NUMERO = OTORGADOS.CUP_NUMERO_CONTRATO (+) 
  AND OTORGADOS.CUP_SUCURSAL_EMISORA = PEDIDOS_FLETE_CAMIONES.PFC_SUCURSAL_EMISORA_CUPO(+) 
  AND OTORGADOS.CUP_NUMERO = PEDIDOS_FLETE_CAMIONES.PFC_NUMERO_CUPO(+) 
  AND PEDIDOS_FLETE_CAMIONES.PFC_PUNTO_EGRESO_BALANZA = EGRESOS_PLANTAS.EPL_PUNTO_EGRESO (+) 
  AND PEDIDOS_FLETE_CAMIONES.PFC_NUMERO_EGRESO_BALANZA = EGRESOS_PLANTAS.EPL_NUMERO_EGRESO (+) 
  AND EGRESOS_PLANTAS.EPL_CAMPO = CAMPOS.CAM_CAMPO (+) 
  AND EGRESOS_PLANTAS.EPL_TIPO_CONTRATO_COMPRA = CONTRATO_COMPRA_EGRESO.CNT_TIPO_CONTRATO(+) 
  AND EGRESOS_PLANTAS.EPL_CONTRATO_COMPRA = CONTRATO_COMPRA_EGRESO.CNT_NUMERO(+) 
  AND CONTRATO_COMPRA_EGRESO.CNT_CORREDOR = CORREDOR_CONTRATO_COMPRA.ENT_CODIGO(+) 
  AND CORREDOR_CONTRATO_COMPRA.ENT_TIPO_ENTIDAD(+) = 3 
  AND CONTRATO_COMPRA_EGRESO.CNT_VENDEDOR = VENDEDOR_CONTRATO_COMPRA.ENT_CODIGO(+) 
  AND VENDEDOR_CONTRATO_COMPRA.ENT_TIPO_ENTIDAD(+) = 3 
GROUP BY 
  CONTRATOS.CNT_NUMERO, 
  CONTRATOS.CNT_COMPRADOR, 
  ENTIDADES.ENT_NOMBRE, 
  CONTRATOS.CNT_ESPECIE, 
  CONTRATOS.CNT_COSECHA, 
  CONTRATOS.CNT_KILOS_PROMEDIO, 
  CONTRATOS.CNT_FECHA_DESDE_ENTREGAS, 
  CONTRATOS.CNT_KILOS_PROMEDIO, 
  NVL (
    CONTRATOS.CNT_KILOS_EXCEDENTES, 
    0
  ), 
  NVL (APLICADO.TOTAL_NETO, 0), 
  NVL (
    APLICADO.TOTAL_ENVIADO_SIN_DESCARGAR, 
    0
  ), 
  NVL (
    APLICADO.KILOS_CUPOS_CUMP_PENDIENTES, 
    0
  ), 
  TRANS_ESPE.KILOS_X_CUPO, 
  NVL (NO_USADOS, 0), 
  USADOS, 
  CONTRATOS.CNT_DESTINO, 
  NO_USADOS, 
  TRIM (CORREDORES.ENT_CODIGO) || ' ' || CORREDORES.ENT_NOMBRE, 
  OTORGADOS.TOTAL_CUPOS_OTORGADOS, 
  TO_CHAR (
    PEDIDOS_FLETE_CAMIONES.PFC_PUNTO_EGRESO_BALANZA, 
    'fm0000'
  ) || '-' || TO_CHAR (
    PEDIDOS_FLETE_CAMIONES.PFC_NUMERO_EGRESO_BALANZA, 
    'fm00000000'
  ), 
  TRIM (ENTIDAD_ENTREGADOR.ENT_CODIGO) || ' ' || ENTIDAD_ENTREGADOR.ENT_NOMBRE, 
  CONTRATOS.CNT_PROCEDENCIA || ' ' || PROCEDENCIA_CNT.PDE_DESCRIPCION, 
  TRIM (
    CAMPOS.CAM_CAMPO || ' ' || CAMPOS.CAM_DESCRIPCION
  ), 
  CUP_NUMERO, 
  CONTRATO_COMPRA_EGRESO.CNT_NUMERO, 
  TRIM (
    CORREDOR_CONTRATO_COMPRA.ENT_CODIGO
  ), 
  CORREDOR_CONTRATO_COMPRA.ENT_NOMBRE, 
  TRIM (
    VENDEDOR_CONTRATO_COMPRA.ENT_CODIGO
  ), 
  VENDEDOR_CONTRATO_COMPRA.ENT_NOMBRE
