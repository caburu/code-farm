#modelos.py

from pydantic import BaseModel, Field
from typing import List, Dict, Any

class RequisicaoCodigo(BaseModel):
    codigo: str
    id_missao: int
    contexto: Dict[str, Any] = {}

class ResultadoAnalise(BaseModel):
    status: str
    mensagens: List[str]
    dados: Dict[str, Any] = {}

class RequisicaoPlantio(BaseModel):
    codigo: str = Field(max_length=10_000)
