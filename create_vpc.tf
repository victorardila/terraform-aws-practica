terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Importar las variables desde el archivo credentials.tfvars
variable "access_key" {}
variable "secret_key" {}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = "us-east-1" # Cambia la región si lo necesitas
}

# Crear VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  #   enable_dns_support   = true
  #   enable_dns_hostnames = true
  tags = {
    Name = "my_vpc"
  }
}
# Crear primera Subnet pública
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24" # Primer bloque CIDR para la subred pública
  availability_zone       = "us-east-1a"  # Zona de disponibilidad A
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_1"
  }
}

# Crear segunda Subnet pública
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24" # Segundo bloque CIDR para la subred pública
  availability_zone       = "us-east-1b"  # Zona de disponibilidad B
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_2"
  }
}

# Crear primera Subnet privada
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.3.0/24" # Primer bloque CIDR para la subred privada
  availability_zone       = "us-east-1c"  # Zona de disponibilidad C
  map_public_ip_on_launch = false

  tags = {
    Name = "private_subnet_1"
  }
}

# Crear segunda Subnet privada
resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.4.0/24" # Segundo bloque CIDR para la subred privada
  availability_zone       = "us-east-1d"  # Zona de disponibilidad D
  map_public_ip_on_launch = false

  tags = {
    Name = "private_subnet_2"
  }
}

# Crear Gateway de Internet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_igw"
  }
}

# Crear tabla de ruteo para las subredes públicas
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  # Añadir una ruta predeterminada a través del Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

# Asociar tabla de ruteo pública con la primera subred pública
resource "aws_route_table_association" "public_route_table_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

# Asociar tabla de ruteo pública con la segunda subred pública
resource "aws_route_table_association" "public_route_table_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Crear tabla de ruteo para las subredes privadas
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "private_route_table"
  }
}

# Asociar tabla de ruteo privada con la primera subred privada
resource "aws_route_table_association" "private_route_table_assoc_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

# Asociar tabla de ruteo privada con la segunda subred privada
resource "aws_route_table_association" "private_route_table_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}
